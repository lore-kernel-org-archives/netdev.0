From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: XFRM and IPv6 raw sockets and multicast
Date: Tue, 4 Dec 2007 17:01:43 +0100
Message-ID: <9c46321e0712040801w72e31178t940ca70ccfd8a14a@mail.gmail.com>
References: <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com>
	 <20071204.075201.108501440.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:33594 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbXLDQBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:01:46 -0500
Received: by ug-out-1314.google.com with SMTP id z38so96230ugc
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 08:01:44 -0800 (PST)
In-Reply-To: <20071204.075201.108501440.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Dec 4, 2007 4:52 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> What do you mean by "ipv6 header"?

  If IPPROTO_RAW is set, we supply the ipv6 header, extensions and payload.

> I think hdrincl is broken (and even, say, deprecated) on IPv6.

  By IPv6 you mean the protocol, or Linux's implementation of it?
Although there are APIs that allow applications to build and supply
the extension headers to the network stack, i think the ability to
provide the full ipv6 packet is also useful for some use cases.

> If we do really support it, if hdcincl is set, XFRM and other
> all extension header processes should be skipped, but they are
> not very clear at all so far.

  I understand how some users of IPPROTO_RAW would want xfrm to be
skipped, but on the other hand i also see the interoperation between
the two as useful, to for instance allowing a ESP tunnel to be used by
such packets.

  Hugo
