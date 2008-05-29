From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix the data length of get destination options
 with short length
Date: Thu, 29 May 2008 17:42:08 +0900 (JST)
Message-ID: <20080529.174208.119722724.yoshfuji@linux-ipv6.org>
References: <483D0070.2090909@cn.fujitsu.com>
	<20080528.201322.26342915.yoshfuji@linux-ipv6.org>
	<483E151B.2000804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org, wangchen@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53554 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbYE2Ilh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:41:37 -0400
In-Reply-To: <483E151B.2000804@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <483E151B.2000804@cn.fujitsu.com> (at Thu, 29 May 2008 10:29:47 +0800), Yang Hongyang <yanghy@cn.fujitsu.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> 
> > POSIX says that the object pointed to by the option_len argument shall be
> > modified to indicate the actual length of the value.
> > Do you think this change conforms to the spec?
> > 
> 
> We use the codes below to get the destination options,the length cnt is half of the option length.
:

Well, actually I reread the spec., and I've found that option_len is
undefined if option_len is not enough for the value.
Current behavior seems okay (according to the spec.), but I'm going to apply
this for consistency with other sockopts if no objections.

--yoshfuji
