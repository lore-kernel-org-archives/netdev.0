From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix the data length of get destination options
 with short length
Date: Wed, 28 May 2008 20:13:22 +0900 (JST)
Message-ID: <20080528.201322.26342915.yoshfuji@linux-ipv6.org>
References: <483D0070.2090909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yjwei@cn.fujitsu.com,
	wangchen@cn.fujitsu.com, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53504 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYE1LMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 07:12:53 -0400
In-Reply-To: <483D0070.2090909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <483D0070.2090909@cn.fujitsu.com> (at Wed, 28 May 2008 14:49:20 +0800), Yang Hongyang <yanghy@cn.fujitsu.com> says:

>   If get destination options with length which is not enough for that
> option,getsockopt() will still return the real length of the option,
> which is larger then the buffer space.
>   This is because ipv6_getsockopt_sticky() returns the real length of
> the option.
> 
> This patch fix this problem.

POSIX says that the object pointed to by the option_len argument shall be
modified to indicate the actual length of the value.
Do you think this change conforms to the spec?

--yoshfuji
