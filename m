From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Date: Fri, 06 Apr 2007 12:24:33 +0900 (JST)
Message-ID: <20070406.122433.60252840.yoshfuji@linux-ipv6.org>
References: <11758281863002-git-send-email-brian.haley@hp.com>
	<4615BCA1.6000608@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dccp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40413 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767516AbXDFDXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 23:23:41 -0400
In-Reply-To: <4615BCA1.6000608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4615BCA1.6000608@hp.com> (at Thu, 05 Apr 2007 23:21:05 -0400), Brian Haley <brian.haley@hp.com> says:

> Add link and site-local scope inline to avoid calls to ipv6_addr_type().
> 

I disagree.  Multicast scopes should also be handled appropriately.

--yoshfuji
