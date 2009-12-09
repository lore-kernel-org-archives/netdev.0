From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][stable] b44 WOL setup: one-bit-off stack corruption
 kernel panic fix
Date: Tue, 08 Dec 2009 21:00:35 -0800 (PST)
Message-ID: <20091208.210035.37560621.davem@davemloft.net>
References: <1259764520.8709.293.camel@hammer.suse.cz>
	<20091202.154220.118775778.davem@davemloft.net>
	<1259852188.8163.58.camel@hammer.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, linux-kernel@vger.kernel.org,
	stable@kernel.org, netdev@vger.kernel.org
To: sbrabec@suse.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750861AbZLIFAd@vger.kernel.org>
In-Reply-To: <1259852188.8163.58.camel@hammer.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stanislav Brabec <sbrabec@suse.cz>
Date: Thu, 03 Dec 2009 15:56:28 +0100

> About 50% of shutdowns of b44 Ethernet adapter ends by kernel panic with
> kernels compiled with stack-protector.
> 
> Checking b44_magic_pattern() return values, one call of
> b44_magic_pattern() returns 127. It means, that set_bit(128, pmask) was
> called on line 1509. It means that bit 0 of 17th byte of pmask was
> overwritten. But pmask has only 16 bytes. Stack corruption happens.
>  
> It seems that set_bit() on line 1509 always writes one bit off.
> 
> The fix does not only solve the stack corruption, but also makes Wake On
> LAN working on my onboard B44 on Asus A7V-333X mainboard.
> 
> It seems that this problem affects all kernel versions since commit
> 725ad800 on 2006-06-20.
> 
> Signed-off-by: Stanislav Brabec <sbrabec@suse.cz>

Applied, thanks.
