From: John Crispin <blogic@openwrt.org>
Subject: Re: [RFC 5/8] net-next: ralink: add support for rt3050 family
Date: Sun, 22 Nov 2015 20:06:56 +0100
Message-ID: <56521250.1060001@openwrt.org>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
 <1448181658-38111-5-git-send-email-blogic@openwrt.org>
 <20151122163632.GA7110@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:35356 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbbKVTHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 14:07:01 -0500
In-Reply-To: <20151122163632.GA7110@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 22/11/2015 17:36, Andrew Lunn wrote:
> On Sun, Nov 22, 2015 at 09:40:55AM +0100, John Crispin wrote:
>> Add support for SoCs from the rt3050 family. This include rt3050, rt3052,
>> rt3352 and rt5350. These all have a builtin 5 port 100mbit switch. This patch
>> includes rudimentary code to power up the switch.
> 
> Hi John
> 
> How do you plan to control this switch?
> 
> Does it make sense to write a DSA driver for it?
> 
>      Andrew
> 

Hi Andrew,

we have had a switch layer inside openwrt called swconfig for several
years. at the moment i have an add-on patch in openwrt to provide an
userland interface via that layer. the driver i have sent will bring up
the switch to a point where traffic flow is possible.

	John
