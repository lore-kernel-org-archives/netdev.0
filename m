From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: TAHI IPv6 testing of kernel 2.6.20
Date: Fri, 16 May 2008 11:42:01 +0900 (JST)
Message-ID: <20080516.114201.99640435.yoshfuji@linux-ipv6.org>
References: <OFAB0C1694.0B207957-ON8525744A.006A249F-8525744A.006A50C8@pt.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: wrs@pt.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48767 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbYEPClm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 22:41:42 -0400
In-Reply-To: <OFAB0C1694.0B207957-ON8525744A.006A249F-8525744A.006A50C8@pt.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFAB0C1694.0B207957-ON8525744A.006A249F-8525744A.006A50C8@pt.com> (at Thu, 15 May 2008 15:21:14 -0400), William Seppeler <wrs@pt.com> says:

> I'm currently testing a 2.6.20 kernel using Self_Test_1.4.14 (performing 
> Phase2 host testing - ipv6ready_p2_host).  It passes all tests except for 
> one.  I'm failing test: 
> 
>     v6LC_2_3_6_G - Redirected to Alternate Router: Invalid (Target Address 
> is Multicast) 

We did not have any issues at that moment, but well,
we have a patch from Brian Haley <brian.haley@hp.com>
(Commit-ID: bf0b48dfc368c07c42b5a3a5658c8ee81b4283ac)
to fix this specific issue.

--yoshfuji
