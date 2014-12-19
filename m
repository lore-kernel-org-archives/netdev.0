From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 22:07:03 +0100
Message-ID: <54949377.5010009@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>	<54948E1F.2080405@gmx.de> <20141219125434.594f4d46@urahara> <549491D2.1090504@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54969 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbaLSVHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 16:07:09 -0500
In-Reply-To: <549491D2.1090504@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 22:00, Lino Sanfilippo wrote:
> On 19.12.2014 21:54, Stephen Hemminger wrote:
>> On Fri, 19 Dec 2014 21:44:15 +0100
>> Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:
>> 
>>> > +	OCTEON_PCI_WIN_READ(oct, CN66XX_CIU_SOFT_RST);
>>> > +	OCTEON_PCI_WIN_WRITE(oct, CN66XX_CIU_SOFT_RST, 1);
>> 
>> Missing a following PCI read to force PCI posting?
>> 
> 
> Yes, I think so.

I thought posting means "writes are delayed", so I wrote it should be
avoided (instead of forced). However I think there should be a PCI read
before the call to mdelay.

Regards,
Lino
