From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/26] e1000: Deprecate mii-tool SIOCMIIREG ioctl
Date: Tue, 29 Aug 2006 16:49:58 -0400
Message-ID: <44F4A876.3050804@pobox.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164432.6872.69323.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38284 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965331AbWH2UuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:50:02 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060829164432.6872.69323.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Deprecate mii-tool SIOCMIIREG ioctl. This ioctl is broken in e1000 and
> ethtool has this functionality in working order.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

This doesn't "deprecated" anything, it changes the ABI on a user's 
machine by _removing_ ioctl handling code that used to be there.

What's broken, and what is needed to fix?  Perhaps e1000 should instead 
be limited to 10/100 networks/speeds?

	Jeff



