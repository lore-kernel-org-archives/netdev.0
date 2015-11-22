From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 5/8] net-next: ralink: add support for rt3050 family
Date: Sun, 22 Nov 2015 17:36:32 +0100
Message-ID: <20151122163632.GA7110@lunn.ch>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
 <1448181658-38111-5-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39119 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbbKVQgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 11:36:36 -0500
Content-Disposition: inline
In-Reply-To: <1448181658-38111-5-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 22, 2015 at 09:40:55AM +0100, John Crispin wrote:
> Add support for SoCs from the rt3050 family. This include rt3050, rt3052,
> rt3352 and rt5350. These all have a builtin 5 port 100mbit switch. This patch
> includes rudimentary code to power up the switch.

Hi John

How do you plan to control this switch?

Does it make sense to write a DSA driver for it?

     Andrew
