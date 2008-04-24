From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Thu, 24 Apr 2008 21:19:53 +0900 (JST)
Message-ID: <20080424.211953.52921169.yoshfuji@linux-ipv6.org>
References: <20080420.183835.02139171.yoshfuji@linux-ipv6.org>
	<dd9c5f130804200342r4bdc938fq4af15c9747ba6e06@mail.gmail.com>
	<20080424.034845.137470754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ellre923@gmail.com, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33464 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbYDXMTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 08:19:55 -0400
In-Reply-To: <20080424.034845.137470754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080424.034845.137470754.davem@davemloft.net> (at Thu, 24 Apr 2008 03:48:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: "chen wang" <ellre923@gmail.com>
> Date: Sun, 20 Apr 2008 18:42:14 +0800
> 
> > 2008/4/20, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>:
> > > RFC3542 tells that IPV6_CHECKSUM socket option in the IPPROTO_IPV6
> > 
> > 
> > 
> >              ^^^^^^^^^^^^^^^^^^^
> > Where in RFC3542 says that "only IPPROTO_IPV6 level" is not allowed to be
> > set
> > IPV6_CHECKSUM option on ICMPv6 socket?
> 
> Yoshifuji-san, please address this question.
> 
> I haven't applied this patch, and I won't until this is resolved
> and discussed.

RFC3542 discusses about IPPROTO_IPV6 level IPV6_CHECKSUM socket option only.
IPPROTO_RAW level IPV6_CHECKSUM socket option is undocumented Linux
extension.  So, we are free to choose allowing setting that option on
ICMPv6 socket as we have been doing.

--yoshfuji
