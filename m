From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC 1/2] TCP: Renaming md5sig to auth
Date: Sat, 19 Jul 2008 09:52:49 +0900 (JST)
Message-ID: <20080719.095249.42274173.yoshfuji@linux-ipv6.org>
References: <396556a20805301217k293e5718h6bbf02bfe069031@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32788 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbYGSAwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:52:51 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069031@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <396556a20805301217k293e5718h6bbf02bfe069031@europa> (at Fri, 18 Jul 2008 17:22:10 -0700), "Adam Langley" <agl@imperialviolet.org> says:

> -struct tcp_md5sig {
> +struct tcp_auth {
>  	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
>  	__u16	__tcpm_pad1;				/* zero */
>  	__u16	tcpm_keylen;				/* key length */

Sorry, you cannot simply change this.  Please #define it at least.
And well, after getting 2nd patch, you should not even change this name.

--yoshfuji
