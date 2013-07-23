From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 23:50:58 +0200
Message-ID: <20130723215058.GA2375@electric-eye.fr.zoreil.com>
References: <4961229.bXDGvH0dpz@al>
 <1765554.SGJMeyexPP@al>
 <20130723202312.GA31567@electric-eye.fr.zoreil.com>
 <7176161.ct75f9bf8d@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51520 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756955Ab3GWVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 17:51:12 -0400
Content-Disposition: inline
In-Reply-To: <7176161.ct75f9bf8d@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> I have not really considered runtime PM before, aren't the ethtool
> operations actually broken with runtime PM enabled ? Or does the ethtool
> core take care of waking devices (which I doubt) ? I don't see any attempt
> to wake devices in the r8169 ethtool operations.

ethtool core bails out.

See dev_ethtool, netif_device_present, rtl8169_net_suspend and
netif_device_detach.

[...]
> > You have the implicit ack of David, so please keep the facts right.
> I am not trying to hide details, before I send the third revision of third 
> commit message, what other details may I have overseen ?

Use netif_dbg instead of removing the message ?

> If you want to, you can also create a patch with an appropriate commit
> message, I don't mind.

[...]
- when no cable is connected.
+ when no cable is connected and runtime power management is disabled.

That's it. Your patch, your credit.

-- 
Ueimor
