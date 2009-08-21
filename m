From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Fri, 21 Aug 2009 09:09:29 +0800
Message-ID: <4A8DF3C9.8000808@cn.fujitsu.com>
References: <20090820111152.GA20295@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57543 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbZHUBJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 21:09:43 -0400
In-Reply-To: <20090820111152.GA20295@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steinar H. Gunderson wrote, at 08/20/2009 07:11 PM:
> Hi,
> 
> I've tried attaching a type-0 routing header to my IPv6 packets with
> setsockopt(..., IPV6_RTHDR, ...), but the kernel just returns EINVAL.
> looking at the source, it seems it simply refuses anything that's not type-2;
> should that really be right? I found the following commit:
> 
>   http://kerneltrap.org/mailarchive/linux-netdev/2008/11/11/4064594
> 
> However, it only seems to change EPERM into EINVAL. I don't see any

About the cause of changing EPERM into EINVAL, can refer to 
http://marc.info/?l=linux-netdev&m=122046709502496&w=3.

-- 
Best Regards
Shan Wei

> reasonable explanation why it should not be simply success; in fact, RFC 3452
> only seems to talk about using type-0 headers with this option.
> 
> Any ideas?
> 
> /* Steinar */

