From: "George Spelvin" <linux@horizon.com>
Subject: Re: Where exactly will arch_fast_hash be used
Date: 8 Dec 2014 11:19:59 -0500
Message-ID: <20141208161959.8852.qmail@ns.horizon.com>
References: <1418037908.190744.200156353.5DD668E8@webmail.messagingengine.com>
Cc: davem@davemloft.net, dborkman@redhat.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: hannes@stressinduktion.org, linux@horizon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418037908.190744.200156353.5DD668E8@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> In case of openvswitch it shows a performance improvment. The seed
>>> parameter could be used as an initial biasing of the crc32 function, but
>>> in case of openvswitch it is only set to 0.
 
>> NACK. [...]

> Sorry for being unclear, I understood that and didn't bother patching
> that '0' with a random seed exactly because of this.

And I'm sorry for delivering a long lecture on a subject you already
understood perfectly well.

I'd just been thinking about it because of Herbert's comments, so it was
conveniently at hand. :-)

Out of curiousity, what *were* you referring to when you talked
about biasing the crc32 function?  "Biasing" is a good term becuase
it just applies an offset, but what do you gain from doing that?


There are nifty things one can do with the CRC32 instruction, however.
A lot of ciphers these days use an ARX (add, rotate, XOR) kernel.
A crc32 instruction, although linear, does some very powerful rotate &
xor operations, and could replace the XOR and rotate.
