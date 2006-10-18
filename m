From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 13:33:50 +0200
Message-ID: <200610181333.50953.netdev@axxeo.de>
References: <4415A4C1.1030906@cosmosbay.com> <4535B6B7.4070107@cosmosbay.com> <20061017.222709.130237201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:20133 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1030238AbWJRLeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 07:34:08 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061017.222709.130237201.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Miller schrieb:
> I don't like these kinds of patches because %99 of people will never
> ever realize the "savings" because distribution vendors will always,
> unlaterally, enable everything.

People producing Linux Appliances DO compile their own kernels.

And some distribution vendors are still at 2.6.8-$WHACKY_PATCHES
or similiar, which is not usable for many things 
(e.g. IPsec, SIP behind NAT etc.).

But I agree that workings towards smaller size in "make allyesconfig"
is much better :-)


Regards

Ingo Oeser
