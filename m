From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next v11 1/1] net: phy: Cleanup the Edge-Rate feature
 in Microsemi PHYs.
Date: Fri, 14 Oct 2016 20:48:39 +0200
Message-ID: <20161014184838.GA9670@microsemi.com>
References: <20161013.100141.1588302672560551253.davem@davemloft.net>
 <1476382890-7275-1-git-send-email-allan.nielsen@microsemi.com>
 <1476382890-7275-2-git-send-email-allan.nielsen@microsemi.com>
 <20161014.110544.269842399219820528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0076.outbound.protection.outlook.com ([104.47.37.76]:19968
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751532AbcJNStp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 14:49:45 -0400
Content-Disposition: inline
In-Reply-To: <20161014.110544.269842399219820528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I'm really sorry if I messed up, or is not following the protocol...

But you have applied it already:
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4f58e6dceb0e44ca8f21568ed81e1df24e55964c

> commit 4f58e6dceb0e44ca8f21568ed81e1df24e55964c
> Author:     Allan W. Nielsen <allan.nielsen@microsemi.com>
> AuthorDate: Wed Oct 12 15:47:51 2016 +0200
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Fri Oct 14 10:06:13 2016 -0400
> 
>     net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
> 
>     Edge-Rate cleanup include the following:
>     - Updated device tree bindings documentation for edge-rate
>     - The edge-rate is now specified as a "slowdown", meaning that it is now
>       being specified as positive values instead of negative (both
>       documentation and implementation wise).
>     - Only explicitly documented values for "vsc8531,vddmac" and
>       "vsc8531,edge-slowdown" are accepted by the device driver.
>     - Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
>     - Read/validate devicetree settings in probe instead of init
> 
>     Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
>     Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Maybe the misunderstanding was caused by me posting the re-based version in
another thread.

Anyway, thanks a lot for the big effort you put into maintaining this
sub-system. I will be more care full next time to avoid such confusions.

Best regards
Allan W. Nielsen





On 14/10/16 11:05, David Miller wrote:
> EXTERNAL EMAIL
> 
> 
> From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
> Date: Thu, 13 Oct 2016 20:21:30 +0200
> 
> > Edge-Rate cleanup include the following:
> > - Updated device tree bindings documentation for edge-rate
> > - The edge-rate is now specified as a "slowdown", meaning that it is now
> >   being specified as positive values instead of negative (both
> >   documentation and implementation wise).
> > - Only explicitly documented values for "vsc8531,vddmac" and
> >   "vsc8531,edge-slowdown" are accepted by the device driver.
> > - Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
> > - Read/validate devicetree settings in probe instead of init
> >
> > Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> > Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>
> 
> This patch does not apply to the net-next tree.
> 
> Take my tree, put this email of your's into a file, and run this:
> 
> bash$ git am file
> 
> and you will get:
> 
> [davem@dhcp-10-15-49-210 net-next]$ git am --signoff net-next-v11-1-1-net-phy-Cleanup-the-Edge-Rate-feature-in-Microsemi-PHYs..patch
> Applying: net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
> error: patch failed: Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt:6
> error: Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt: patch does not apply
> error: patch failed: drivers/net/phy/mscc.c:12
> error: drivers/net/phy/mscc.c: patch does not apply
> error: include/dt-bindings/net/mscc-phy-vsc8531.h: does not exist in index
> Patch failed at 0001 net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
> The copy of the patch that failed is found in:
>    /home/davem/src/GIT/net-next/.git/rebase-apply/patch
> When you have resolved this problem, run "git am --continue".
> If you prefer to skip this patch, run "git am --skip" instead.
> To restore the original branch and stop patching, run "git am --abort".
> 
> Please do not resubmit this patch until you can successfully email the
> patch to yourself and apply it cleanly to the net-next tree.
> 
> 
