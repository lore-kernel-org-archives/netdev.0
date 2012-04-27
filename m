From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ss: implement -M option to get all memory
 information
Date: Fri, 27 Apr 2012 10:21:38 -0700
Message-ID: <20120427102138.67bd6b3a@nehalam.linuxnetplumber.net>
References: <4F97A48F.4010109@gmail.com>
	<20120425104128.4d6e13e1@nehalam.linuxnetplumber.net>
	<4F99FEA1.2000700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39978 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760638Ab2D0RWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 13:22:17 -0400
In-Reply-To: <4F99FEA1.2000700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Apr 2012 10:04:17 +0800
Shan Wei <shanwei88@gmail.com> wrote:

> Stephen Hemminger said, at 2012/4/26 1:41:
> 
> >>  "   -m, --memory        show socket memory usage\n"
> >> +"   -M, --skmem         show socket memory information.\n"
> >> +"                       this option which will replace -m, is valid since Linux 3.3.\n"
> > 
> > Please don't add reference to kernel version.
> > Why does this need to be a new option? Maybe just do the right thing
> > if present in the netlink response?
> 
> 
> Actually, I'm ok for your suggestion that using a existing option(-m) to
> export all memory information. But with a new option is better for us.

Why? if you are arguing to replace the option anyway.

> Maybe some people use latest iproute source with under kernel 3.3.0, some don't.
> -m option will take different user experience, specially for UDP socket.
> Currently -m option has no effect on UDP socket which i will submit another patch
> to export memory information for. new option, fresh experience.

Lots of options return more or different information based on kernel
version, probably the biggest example is how stats are processed.

> (Exporting out memory information will help us to analysis dropped packets 
> which recorded in RcvbufErrors and SndbufErrors.)
>  
> 
>  
> 
