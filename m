From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 19:14:59 +0800
Message-ID: <50A4CEB3.1050709@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352969771.3499.34.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25203 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993097Ab2KOLPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 06:15:11 -0500
In-Reply-To: <1352969771.3499.34.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 16:56, Ian Campbell wrote:
> On Thu, 2012-11-15 at 07:03 +0000, Annie Li wrote:
>
>> This patch implements persistent grants for xen-netfront/netback. This
>> mechanism maintains page pools in netback/netfront, these page pools
>> is used to save grant pages which are mapped. This way improve
>> performance which is wasted when doing grant operations.
> Please can you send a patch against xen-unstable.hg to document this new
> protocol variant in xen/include/public/io/netif.h. This header is a bit
> under-documented but lets not let it fall further behind (if you want to
> go further and document the existing features, in the style of the
> current blkif.h, then that would be awesome!).
Ok, no problem.
>
> You may also want to provide a similar patch to Linux's copy which is in
> linux/include/xen/interface/io/netif.h
Ok, will do that.

Thanks
Annie
>
> Ian.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
