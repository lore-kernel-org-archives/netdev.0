From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v2] r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 22:48:51 +0200
Message-ID: <7176161.ct75f9bf8d@al>
References: <4961229.bXDGvH0dpz@al> <1765554.SGJMeyexPP@al> <20130723202312.GA31567@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:55432 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966Ab3GWUs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:48:56 -0400
Received: by mail-wg0-f49.google.com with SMTP id a12so7682119wgh.16
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 13:48:55 -0700 (PDT)
In-Reply-To: <20130723202312.GA31567@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 July 2013 22:23:12 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> > This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
> > link handling and phy reset rework) and is printed every ten seconds
> > when no cable is connected.
> 
> +                            and runtime power management is disabled.
> It isn't completely academic: Fedora has it enabled.
I have not really considered runtime PM before, aren't the ethtool operations 
actually broken with runtime PM enabled? Or does the ethtool core take care of 
waking devices (which I doubt)? I don't see any attempt to wake devices in the 
r8169 ethtool operations.

> You have the implicit ack of David, so please keep the facts right.
I am not trying to hide details, before I send the third revision of third 
commit message, what other details may I have overseen? If you want to, you 
can also create a patch with an appropriate commit message, I don't mind.

Regards,
Peter
