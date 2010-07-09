From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] cxgb4vf: remove obsolete DECLARE_PCI_UNMAP_ADDR usage
Date: Fri, 09 Jul 2010 15:12:40 +0900
Message-ID: <20100709151240M.fujita.tomonori@lab.ntt.co.jp>
References: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
	<20100708190126X.fujita.tomonori@lab.ntt.co.jp>
	<20100708.230939.102558536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, leedom@chelsio.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:57012 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012Ab0GIGPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:15:06 -0400
In-Reply-To: <20100708.230939.102558536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jul 2010 23:09:39 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > btw, I'm not sure that seeing if a platform does real DMA unmapping in
> > a driver is a good thing. But I suppose that we need to accept it if
> > this leads to big performance boost.
> > 
> > Both can be applied to net-next.
> 
> I think the value of these "optimizations" is rapidly decreasing to
> zero.  And I believe I've told the authors of either this driver or
> another one that they should just remove this stuff completely.

I prefer to remove this stuff completely too.

If this trick improves the performance greatly, we could add this to
the DMA API (that's better than adding such ifdef hack to drivers).
