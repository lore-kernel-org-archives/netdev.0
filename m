From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Wed, 07 Apr 2010 20:59:47 -0700 (PDT)
Message-ID: <20100407.205947.188334514.davem@davemloft.net>
References: <20100405071059.GA32671@serverengines.com>
	<20100405163942P.fujita.tomonori@lab.ntt.co.jp>
	<20100405082202.GB32671@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756428Ab0DHD7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 23:59:44 -0400
In-Reply-To: <20100405082202.GB32671@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 5 Apr 2010 13:52:02 +0530

> On 05/04/10 16:40 +0900, FUJITA Tomonori wrote:
>> > > +		wrb->frag_len = 0;
>> > Why does wrb->frag_len need to be reset here?
>> > In the TX path, it is set to the proper value for data wrbs and zero
>> > for dummy and hdr wrbs.
>> 
>> I guess that I misunderstood why unmap_tx_frag() checks a dma address.
>> The checking is necessary to avoid calling pci_unamp_* API for dummy
>> hdr wrbs?
> Yes.
>> 
>> Anyway, if wrb->frag_len doesn't need to be reset here, the following
>> patch is ok?
> Yes. Thanks.
> 
> Acked-by: Sathya Perla <sathyap@serverengines.com>

Applied to net-next-2.6
