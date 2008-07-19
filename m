From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC 2/2] TCP: Add TCP-AO support
Date: Sat, 19 Jul 2008 10:28:38 +0900 (JST)
Message-ID: <20080719.102838.76205933.yoshfuji@linux-ipv6.org>
References: <396556a20805301217k293e5718h6bbf02bfe069032@europa>
	<20080719.100648.63386563.yoshfuji@linux-ipv6.org>
	<396556a20807181816qdb50221nc0aa259d3fb3395d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32797 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbYGSB2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:28:40 -0400
In-Reply-To: <396556a20807181816qdb50221nc0aa259d3fb3395d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <396556a20807181816qdb50221nc0aa259d3fb3395d@mail.gmail.com> (at Fri, 18 Jul 2008 18:16:52 -0700), "Adam Langley" <agl@imperialviolet.org> says:

> >      __u16   tcpa_txkey;
> 
> You can only specify 256 keys on the wire, so this only need be a __u8

okay.

Again, is it okay to add/del one key per each operation?
If yes, we do not need to change current API too much.

--yoshfuji
