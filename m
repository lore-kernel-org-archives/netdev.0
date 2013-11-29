From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: smc91: fix crash regression on the versatile
Date: Fri, 29 Nov 2013 16:23:57 -0500 (EST)
Message-ID: <20131129.162357.448986999180982807.davem@davemloft.net>
References: <1385645632-3577-1-git-send-email-linus.walleij@linaro.org>
	<20131128172442.GC16203@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linus.walleij@linaro.org, netdev@vger.kernel.org, nico@fluxnic.net,
	linux@arm.linux.org.uk, eric.y.miao@gmail.com, jic23@cam.ac.uk,
	stable@vger.kernel.org
To: will.deacon@arm.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131128172442.GC16203@mudshark.cambridge.arm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Will Deacon <will.deacon@arm.com>
Date: Thu, 28 Nov 2013 17:24:42 +0000

> On Thu, Nov 28, 2013 at 01:33:52PM +0000, Linus Walleij wrote:
>> After commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90
>> "net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data"
>> The Versatile SMSC LAN91C111 is crashing like this:
> 
> [...]
> 
>> ---
>> ChangeLog v2->v3:
>> - Fold in a hunk from Will Deacon's patch addressing the same
>>   issue.
>> ChangeLog v1->v2:
>> - Correct commit message to nail the actual commit causing
>>   the bug, as pointed out by Russell.
>> ---
>>  drivers/net/ethernet/smsc/smc91x.h | 22 ++++------------------
>>  1 file changed, 4 insertions(+), 18 deletions(-)
> 
>   Acked-by: Will Deacon <will.deacon@arm.com>
> 
> Cheers for sorting that out, Linus.

Applied, thanks.
