From: Michael Chan <mchan@broadcom.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue timed out" when
 skb has huge linear buffer
Date: Tue, 4 Feb 2014 11:47:51 -0800
Message-ID: <1391543271.4804.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <52EAA31B.1090606@schaman.hu>
	 <1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <52EBA51E.808@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@schaman.hu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:21382 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbaBDTrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 14:47:52 -0500
In-Reply-To: <52EBA51E.808@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-31 at 14:29 +0100, Zoltan Kiss wrote: 
> [ 5417.275472] WARNING: at net/sched/sch_generic.c:255 
> dev_watchdog+0x156/0x1f0()
> [ 5417.275474] NETDEV WATCHDOG: eth1 (bnx2): transmit queue 2 timed out 

The dump shows an internal IRQ pending on MSIX vector 2 which matches
the the queue number that is timing out.  I don't know what happened to
the MSIX and why the driver is not seeing it.  Do you see an IRQ error
message from the kernel a few seconds before the tx timeout message?
