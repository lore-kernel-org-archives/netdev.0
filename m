From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ethernet/atheros/alx: sanitize buffer
 sizing and padding
Date: Wed, 06 Jan 2016 15:05:39 -0500 (EST)
Message-ID: <20160106.150539.179421707935774818.davem@davemloft.net>
References: <20160106.012326.1058946039396006074.davem@davemloft.net>
	<1452090997-27683-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, eugene.shatokhin@rosalab.ru,
	prudy1@o2.pl, jcliburn@gmail.com, chris.snook@gmail.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452090997-27683-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Wed,  6 Jan 2016 09:36:37 -0500

> This is based on the work done by Przemek Rudy in bug 70761 at
> bugzilla.kernel.org, but with some work done to disentagle and clarify
> things a bit.
> 
> Similar to Przemek's work and other drivers, we're adding a padding of 16
> here, but we're also disentangling mtu size calculations from max buffer
> size calculations a bit, and adding ETH_HLEN to the value written into
> ALX_MTU. Hopefully, with a bit more consistency and clarity, things behave
> better here. Sadly, I can only test in my alx-driven E2200, which worked
> just fine before this patch.
> 
> In comment #58 of bug 70761, Eugene A. Shatokhin reports that this patch
> does help considerably for a ROSA Linux user of his with an AR8162 network
> adapter when patched into a 4.1.x-based kernel, with several days of
> normal operation where wired network previously wasn't usable without
> setting MTU to 9000 as a work-around.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
> CC: "Eugene A. Shatokhin" <eugene.shatokhin@rosalab.ru>
> CC: Przemek Rudy <prudy1@o2.pl>
> CC: Jay Cliburn <jcliburn@gmail.com>
> CC: Chris Snook <chris.snook@gmail.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> v2: remove superfluous parens around raw_mtu, pointed out by davem

Looks great, applied, thanks Jarod.
