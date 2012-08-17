From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] smsc75xx: add missing entry to MAINTAINERS
Date: Fri, 17 Aug 2012 09:21:57 -0700
Message-ID: <1345220517.8407.3.camel@joe2Laptop>
References: <1345103618-22753-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	trivial@rustcorp.com.au
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53290 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757164Ab2HQQV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 12:21:59 -0400
In-Reply-To: <1345103618-22753-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-16 at 08:53 +0100, Steve Glendinning wrote:
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> +USB SMSC75XX ETHERNET DRIVER
> +M:	Steve Glendinning <steve.glendinning@shawell.net>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/usb/smsc75xx.*
> +
>  USB SMSC95XX ETHERNET DRIVER
>  M:	Steve Glendinning <steve.glendinning@shawell.net>
>  L:	netdev@vger.kernel.org

Hi Steve.

Perhaps you could have a single updated [79]5xx entry with
F:	drivers/net/usb/smsc[79]5xx.*

or

F:	drivers/net/usb/smsc?5xx.*

Also, diff makes it seem the drivers aren't significantly
different.  Might it be better to integrate the 2 drivers
into a single driver that supports both?
