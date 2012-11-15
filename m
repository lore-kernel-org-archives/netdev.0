From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 08:56:11 +0000
Message-ID: <1352969771.3499.34.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:7329 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992885Ab2KOI4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:56:13 -0500
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 07:03 +0000, Annie Li wrote:

> 
> This patch implements persistent grants for xen-netfront/netback. This
> mechanism maintains page pools in netback/netfront, these page pools
> is used to save grant pages which are mapped. This way improve
> performance which is wasted when doing grant operations. 

Please can you send a patch against xen-unstable.hg to document this new
protocol variant in xen/include/public/io/netif.h. This header is a bit
under-documented but lets not let it fall further behind (if you want to
go further and document the existing features, in the style of the
current blkif.h, then that would be awesome!).

You may also want to provide a similar patch to Linux's copy which is in
linux/include/xen/interface/io/netif.h

Ian.
