From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 12:54:34 -0800
Message-ID: <20141219125434.594f4d46@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<54948E1F.2080405@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:51727 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaLSUyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 15:54:45 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so1904489pdi.30
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 12:54:45 -0800 (PST)
In-Reply-To: <54948E1F.2080405@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2014 21:44:15 +0100
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> > +	OCTEON_PCI_WIN_READ(oct, CN66XX_CIU_SOFT_RST);
> > +	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_RST, 1);

Missing a following PCI read to force PCI posting?
