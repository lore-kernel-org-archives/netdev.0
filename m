From: John Crispin <blogic@openwrt.org>
Subject: Re: [RFC 5/8] net-next: ralink: add support for rt3050 family
Date: Mon, 23 Nov 2015 07:47:32 +0100
Message-ID: <5652B684.50508@openwrt.org>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
 <1448181658-38111-5-git-send-email-blogic@openwrt.org>
 <20151122163632.GA7110@lunn.ch> <56521250.1060001@openwrt.org>
 <20151122231601.GA9582@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:50022 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbbKWGrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 01:47:41 -0500
In-Reply-To: <20151122231601.GA9582@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 23/11/2015 00:16, Andrew Lunn wrote:
>> Hi Andrew,
>>
>> we have had a switch layer inside openwrt called swconfig for several
>> years. at the moment i have an add-on patch in openwrt to provide an
>> userland interface via that layer.
> 
> Hi John
> 
> I know of swconfig.  However, it has been NACKed for mainline. So you
> either need to do switchdev or DSA for controlling switches in
> mainline.
> 
> 	Andrew
> 

Hi Andrew.

I am not planning to bring the switch support upstream in the near
future. right now my focus is on bringing the core driver upstream. once
that is done i plan so add support for the new DMA core, then the new
ARM SoCs. once those are done i plan to add support for the new media
center SoC and once that is done i am probably going to have a go at the
hw offloading engine. Once all that is done, i will have time to look at
the switch driver. however that wont happen in the near future.

	John
