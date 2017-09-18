From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6_skip_exthdr: use ipv6_authlen for AH header
 length computation
Date: Mon, 18 Sep 2017 14:53:33 -0700 (PDT)
Message-ID: <20170918.145333.387149087319576031.davem@davemloft.net>
References: <CAMtaSwRk0ne+kG3ejH6685N=ByEAVOkvtyCbmPu9jTng3h2YNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: qasdfgtyuiop@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdIRVxe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:53:34 -0400
In-Reply-To: <CAMtaSwRk0ne+kG3ejH6685N=ByEAVOkvtyCbmPu9jTng3h2YNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiang Gao <qasdfgtyuiop@gmail.com>
Date: Fri, 15 Sep 2017 01:04:27 -0400

> From 09cf2e3cf09cf591283785aaa8159baf39ac2e08 Mon Sep 17 00:00:00 2001
> From: Xiang Gao <qasdfgtyuiop@gmail.com>
> Date: Fri, 15 Sep 2017 00:44:12 -0400
> Subject: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen
> 
> In ipv6_skip_exthdr, the lengh of AH header is computed manually
> as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
> named ipv6_authlen is already defined for exactly the same job. This
> commit replaces the manual computation code with the macro.

Your patch was whitespace corrupted by your email client.
