From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v4 0/5] xen-netback: IPv6 offload
 support
Date: Wed, 16 Oct 2013 17:20:01 +0100
Message-ID: <1381940401.30409.9.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23387 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760004Ab3JPQUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:20:04 -0400
In-Reply-To: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> This patch series adds support for checksum and large packet offloads into
> xen-netback.
> Testing has mainly been done using the Microsoft network hardware
> certification suite running in Server 2008R2 VMs with Citrix PV frontends.

Are there any Linux netfront patches in existence/the pipeline to take
advantage of this?

> 
> v2:
> - Fixed Wei's email address in Cc lines
> 
> v3:
> - Responded to Wei's comments:
>  - netif.h now updated with comments and a definition of
>    XEN_NETIF_GSO_TYPE_NONE.
>  - limited number of pullups
> - Responded to Annie's comments:
>  - New GSO_BIT macro
> 
> v4:
> - Responded to more of Wei's comments
> - Remove parsing of IPv6 fragment header and added warning
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
