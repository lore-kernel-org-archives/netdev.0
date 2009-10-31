From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: Net driver module dependencies on PHY driver modules
Date: Sat, 31 Oct 2009 09:34:13 -0600
Message-ID: <4AEC58F5.2030905@canonical.com>
References: <1256989326.3136.284.camel@localhost>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>, 553024@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:1519 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbZJaPdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Oct 2009 11:33:25 -0400
In-Reply-To: <1256989326.3136.284.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> I'm handling a bug report <http://bugs.debian.org/553024> relating to
> tg3 using phylib and missing the broadcom module.
> 
> There seem to be two general problems here:
> 1. PHY drivers are not auto-loaded
> 2. An initramfs builder cannot statically determine that a net device
> requires a PHY driver
> 
> It seems to me that PHY drivers should have aliases based on MDIO PHY
> ids, and phylib should request_module() if no suitable driver is
> registered.  This would solve (1) and go some way to solving (2).
> 
> Ben.
> 

I encountered the same issue with Karmic and worked around it by
building in all of the phylib modules, e.g., CONFIG_BROADCOM_PHY=y. I
agree that its not the best long term solution.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
