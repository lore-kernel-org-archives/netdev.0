From: David Miller <davem@davemloft.net>
Subject: Re: is each frag of a skb always less than 1 page?
Date: Tue, 10 Oct 2006 15:47:32 -0700 (PDT)
Message-ID: <20061010.154732.110906680.davem@davemloft.net>
References: <ba020e9f0610101537m492a957fj982097c8d7f407e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:695
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030617AbWJJWrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 18:47:32 -0400
To: ronghuazhang@gmail.com
In-Reply-To: <ba020e9f0610101537m492a957fj982097c8d7f407e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ronghua Zhang" <ronghuazhang@gmail.com>
Date: Tue, 10 Oct 2006 15:37:04 -0700

> >From the code of tcp_sendmsg, it seems to me that each frag is at most
> one page. Is it a guaranteed property or the driver should not assume
> it? Thanks

This assumption basically already exists everywhere since
all drivers that create DMA mappings of the frags call
pci_map_page().
