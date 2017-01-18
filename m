From: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>
Subject: RE: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Wed, 18 Jan 2017 03:20:23 +0000
Message-ID: <337A096076BEF646A1F21E1AD855580E3AC8F757@g01jpexmbkw23>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
 <20170117.154512.612465430064515761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:59353 "EHLO
        mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751179AbdARDUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 22:20:33 -0500
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
        by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 941BCAC0187
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 12:20:25 +0900 (JST)
In-Reply-To: <20170117.154512.612465430064515761.davem@davemloft.net>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, January 18, 2017 5:45 AM
> To: Ashizuka, Yuusuke/芦塚 雄介
> Cc: fugang.duan@nxp.com; netdev@vger.kernel.org
> Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
> 
> From: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
> Date: Tue, 17 Jan 2017 16:48:20 +0900
> 
> > If highmem and 2GB or more of memory are valid, "this_frag-> page.p"
> > indicates the highmem area, so the result of page_address() is NULL
> > and panic occurs.
> >
> > This commit fixes this by using the skb_frag_dma_map() helper, which
> > takes care of mapping the skb fragment properly. Additionally, the
> > type of mapping is now tracked, so it can be unmapped using
> > dma_unmap_page or dma_unmap_single when appropriate.
> 
> This patch submission is lacking a proper signoff.

Thank you for pointing out my mistake.
I will submit the patch again.
