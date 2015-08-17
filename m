From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Mon, 17 Aug 2015 11:43:20 +0200
Message-ID: <55D1ACB8.3040500@ahsoftware.de>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <55B89C14.2070700@ahsoftware.de> <55BA1144.9090203@ahsoftware.de>
 <55CEEECA.8000702@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CEEECA.8000702@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 15.08.2015 um 09:48 schrieb Alexander Holler:
> Am 30.07.2015 um 13:57 schrieb Alexander Holler:
>> Am 29.07.2015 um 11:25 schrieb Alexander Holler:
>>> Am 23.05.2015 um 05:55 schrieb Martin KaFai Lau:

> To complete the discussion, that "annoying behaviour" is also a big
> information leak.
>
> Because routes aren't considered confidential and aren't subject to
> privacy, that broken behaviour enabled *everyone* on the same system to
> see *all* the remote IPv6 systems to which there have been connection
> establishment tries.

Just in case I haven't described the problem I see clearly enough:

"Everyone" means everything (other SW) too, and if "Happy_Eyeballs" 
algorithms are used (see RFC 6555), this also affects systems which only 
have an IPv4 connection to the world, as long as IPv6 is enabled.

That means it does not only affect multiuser systems and the current 
behaviour of kernels < 4.2 renders e.g. the private mode of most 
browsers somewhat useless too (in regard to protection against other SW 
and/or users running on the same system).

That's why I vote to check out if it's possible/reasonable to backport 
this series to the stable kernels.

Regards,

Alexander Holler
