From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 4/6] netback: add module get/put
 operations along with vif connect/disconnect.
Date: Mon, 16 Jan 2012 09:43:24 +0000
Message-ID: <1326707004.5285.8.camel@liuw-desktop>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-5-git-send-email-wei.liu2@citrix.com>
	 <4F107B89.6000004@cantab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <dvrabel@cantab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:27810 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab2APJoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 04:44:11 -0500
In-Reply-To: <4F107B89.6000004@cantab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-13 at 18:44 +0000, David Vrabel wrote:
> On 13/01/12 16:59, Wei Liu wrote:
> > If there is vif running and user unloads netback, it will certainly
> > cause problems.
> 
> Is this necessary?  As part of module unload netback_remove() will be
> called and this will clean everything correctly, yes?
> 

You're right here from the host's perspective of view. Everything gets
cleaned up.

But from the guest's perspective of view, its network interface just
mysteriously stops working.

So my "problems" in the above statements comes from guest, will make
commit message more clear.


Wei.
