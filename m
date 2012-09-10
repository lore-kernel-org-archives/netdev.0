From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: RFC - document network device carrier management
Date: Mon, 10 Sep 2012 04:00:11 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209100355370.22738@frira.zrqbmnf.qr>
References: <20120815085827.2b252094@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:51402 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755905Ab2IJCAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2012 22:00:13 -0400
In-Reply-To: <20120815085827.2b252094@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2012-08-15 17:58, Stephen Hemminger wrote:
>--- a/Documentation/networking/netdevices.txt	2012-06-22 08:27:46.729168196 -0700
>+++ b/Documentation/networking/netdevices.txt	2012-08-15 08:56:31.120429994 -0700
>@@ -45,6 +45,36 @@ drop, truncate, or pass up oversize pack
> packets is preferred.
> 
> 
>+CARRIER
>+=======
>+Most network devices have an operational state that the device
>+monitors. The Linux kernel uses the name "carrier" for this flag which
>+is a historical reference to old modems. Carrier is reported to
>+userspace via the IFF_RUNNING flag from SIOCGIFFLAGS ioctl.

I think Netlink should be mentioned instead:

Carrier is reported to userspace via the IFF_RUNNING flag in
struct ifinfomsg.ifi_flags returned by RTM_GETLINK (see rtnetlink(7)).
