From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Reduce locking in TX path of forcedth driver
Date: Sat, 22 Dec 2007 21:13:52 -0500
Message-ID: <476DC460.6030701@garzik.org>
References: <20071222014134.A28994161A0@localhost>	 <20071221185435.2884f118@deepthought> <476C89BE.9050700@garzik.org> <65634d660712212149ua4f083dw80c65ea884902771@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36666 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567AbXLWCN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2007 21:13:59 -0500
In-Reply-To: <65634d660712212149ua4f083dw80c65ea884902771@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> 
>     (Tom, you failed to CC the maintainer at NVIDIA, please fix...)
> 
>  
> Jeff,
>  
> Please pardon my naivety, but how would determine who the maintainer at 
> NVDIA is?  The MAINTAINERS file lists an Nvidia maintainer only for the 
> framebuffer driver, and I don't see this specified in the source file.

In general, you want to check with

	git log drivers/net/forcedeth.c

in addition to MAINTAINERS, to see who is actively working on the driver.

In this case, the original authors are largely idle (though still 
respond to emails), and NVIDIA has been doing most of the maintenance 
for the past year or more.

MAINTAINERS certainly wants fixing though, if it doesn't reflect the 
current situation.

	Jeff



