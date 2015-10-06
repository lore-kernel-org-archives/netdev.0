From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg
 is marked volatile
Date: Mon, 05 Oct 2015 23:29:56 -0700 (PDT)
Message-ID: <20151005.232956.105884641412802470.davem@davemloft.net>
References: <1444051772-20270-1-git-send-email-jon@ringle.org>
	<20151005145722.GT12635@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: broonie@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151005145722.GT12635@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Brown <broonie@kernel.org>
Date: Mon, 5 Oct 2015 15:57:22 +0100

> On Mon, Oct 05, 2015 at 09:29:31AM -0400, jon@ringle.org wrote:
>> From: Jon Ringle <jringle@gridpoint.com>
>> 
>> The only time that it makes sense to call a custom provided reg_update_bits
>> function, is the register being updated is one that has volatile bits.
>> Otherwise, the normal read/modify/write cycle (where the read is likely to
>> be free from the cache) will do just fine. This should keep the reg cache
>> intact, since volatile registers won't get cached anyway.
> 
> Dave, to be clear please do *not* apply this patch at least for the time
> being - I've not reviewed it or the one from Thursday that you applied
> this morning.

It's applied, it's pushed out to my tree, and therefore this will need to
be fixed up with a relative patch of some sort.

What you don't seem to understand is that my GIT tree is never rebased
or mangled because many people depend upon it.  So once a patch is
applied, that commit lives on forever.
