From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netback: enable user to unload
 netback module
Date: Tue, 7 May 2013 14:00:29 +0100
Message-ID: <1367931629.26321.121.camel@zakaz.uk.xensource.com>
References: <1367856706-5131-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:62360 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808Ab3EGNAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 09:00:31 -0400
In-Reply-To: <1367856706-5131-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-06 at 17:11 +0100, Wei Liu wrote:
> This patch enables user to unload netback module, which is useful when user
> wants to upgrade to a newer netback module without rebooting the host.
> 
> Netfront cannot handle netback removal event. As we cannot fix all possible
> frontends we add module get / put along with vif get / put to avoid
> mis-unloading of netback. To unload netback module, user needs to shutdown
> all VMs or migrate them to another host before hand.

... or just unplug their VIFs.

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
(when the tree reopens of course)

Ian.
