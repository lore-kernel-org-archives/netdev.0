From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Mon, 7 Nov 2016 10:55:32 +0100
Message-ID: <20161107095532.GD16599@microsemi.com>
References: <20161107022628.GA21529@yexl-desktop>
 <20161107093148.GA27001@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <lkp@01.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0042.outbound.protection.outlook.com ([104.47.41.42]:58113
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752312AbcKGJzr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 04:55:47 -0500
Content-Disposition: inline
In-Reply-To: <20161107093148.GA27001@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm quite surprised too.

I asked Raju to see if he can re-produce, and then try again with the
microsemi_phy disabled and see it that makes a difference.

If Raju gets stuck on this, then I will try to help our during the after-noon.

/Allan

On 07/11/16 10:31, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Mon, Nov 07, 2016 at 10:26:28AM +0800, kernel test robot wrote:
> >
> > FYI, we noticed the following commit:
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > commit af1fee98219992ba2c12441a447719652ed7e983 ("net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY")
> 
> Humm, interesting. I've no idea how this patch can trigger such a
> warning. The USB gadget does not have an Ethernet PHY, let alone a
> Microsemi 8530/40 Fast Ethernet PHY this patch adds.
> 
> However, it seems nicely documented how to reproduce this. Allan, can
> you setup such a system? Reproduce it, then revert the change and see
> if it still happens.
> 
>    Andrew
