From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH review] b44: Port to ssb subsystem
Date: Wed, 07 Feb 2007 14:36:42 -0800
Message-ID: <1170887802.15655.14.camel@dhcp-10-7-81-58.broadcom.com>
References: <200701231720.36370.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3106 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422808AbXBGW7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 17:59:09 -0500
In-Reply-To: <200701231720.36370.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-23 at 17:20 +0100, Michael Buesch wrote:
> This patch ports b44 to the new SSB subsystem and makes
> it possible to turn off PCI related stuff.
> 
> This patch is against my tree, where I have implemented the
> ssb subsystem.
> 
> If you're all OK with this patch, I'd like apply it to my tree.
> I think that's best. Although it's not wireless-related, it's
> much easier to maintain this way.

>  
> +static int b44_ethtool_ioctl (struct net_device *dev, void __user *useraddr)

Michael, Do you really want to create ethtool_ioctl() to do what the
ethtool_ops does?

-Gary


