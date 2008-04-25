From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Thu, 24 Apr 2008 21:31:10 -0700 (PDT)
Message-ID: <20080424.213110.202702419.davem@davemloft.net>
References: <dd9c5f130804200342r4bdc938fq4af15c9747ba6e06@mail.gmail.com>
	<20080424.034845.137470754.davem@davemloft.net>
	<20080424.211953.52921169.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ellre923@gmail.com, wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751493AbYDYEbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 00:31:16 -0400
In-Reply-To: <20080424.211953.52921169.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Apr 2008 21:19:53 +0900 (JST)

> In article <20080424.034845.137470754.davem@davemloft.net> (at Thu, 24 Apr 2008 03:48:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: "chen wang" <ellre923@gmail.com>
> > Date: Sun, 20 Apr 2008 18:42:14 +0800
> > 
> > > 2008/4/20, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>:
> > > > RFC3542 tells that IPV6_CHECKSUM socket option in the IPPROTO_IPV6
> > > 
> > > 
> > > 
> > >              ^^^^^^^^^^^^^^^^^^^
> > > Where in RFC3542 says that "only IPPROTO_IPV6 level" is not allowed to be
> > > set
> > > IPV6_CHECKSUM option on ICMPv6 socket?
> > 
> > Yoshifuji-san, please address this question.
> > 
> > I haven't applied this patch, and I won't until this is resolved
> > and discussed.
> 
> RFC3542 discusses about IPPROTO_IPV6 level IPV6_CHECKSUM socket option only.
> IPPROTO_RAW level IPV6_CHECKSUM socket option is undocumented Linux
> extension.  So, we are free to choose allowing setting that option on
> ICMPv6 socket as we have been doing.

Thank you for this clarification.

I've applied this patch and I'll queue it up for -stable as well.

Thanks again.
