From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 05 Oct 2006 15:06:34 +0900 (JST)
Message-ID: <20061005.150634.27869684.yoshfuji@linux-ipv6.org>
References: <20061005053531.GA19482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:31503 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750803AbWJEGEM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 02:04:12 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20061005053531.GA19482@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061005053531.GA19482@gondor.apana.org.au> (at Thu, 5 Oct 2006 15:35:31 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Are there any non-multicast interfaces that require addrconf?
> In other words, what does the following patch break :)

Why do you want to do this?  Xen issue?

As Alexey mentioned before, addrconf should work even for !MULTICAST &&
BROADCAST.  This is true for POINTOPOINT as well; ISATAP will use this.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
