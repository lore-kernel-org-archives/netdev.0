From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Sun, 24 Oct 2010 15:44:17 -0700 (PDT)
Message-ID: <20101024.154417.116368884.davem@davemloft.net>
References: <AANLkTinBGP1gzUCFN2n1xBGZydEnUKoZYPKd1_WbF1gY@mail.gmail.com>
	<89E2752CFA8EC044846EB8499819134102BF28D66D@EXCH-MBX-4.vmware.com>
	<AANLkTimy5Pg1aUMfCZG+r+Zb=A_udx8NsYf3TXVHHTsf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41266
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933129Ab0JXWny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:43:54 -0400
In-Reply-To: <AANLkTimy5Pg1aUMfCZG+r+Zb=A_udx8NsYf3TXVHHTsf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Fri, 22 Oct 2010 10:52:15 -0700

> On Fri, Oct 22, 2010 at 10:46 AM, Shreyas Bhatewara
> <sbhatewara@vmware.com> wrote:
>>> From: Harvey Harrison [mailto:harvey.harrison@gmail.com]
>>> One question I had when looking into this, why are you doing
>>> byteswapping in the VMXNET_{READ,WRITE}_BAR{0,1}
>>> macros?
>>
>> Because values need to be written in LE orders in registers. For eg. when rx_ring.next2fill index is written to RXPROD reg, it should be converted from CPU order to LE.
> 
> Yes, but (unless I'm mistaken) writel always writes out in
> little-endian, so there isn't a need to swap the arguments,
> similarly for readl in the other direction.

That's right, readl() and writel() translate to little-endian.


