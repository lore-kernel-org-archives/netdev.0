From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 15/21] net: dsa: mv88e6xxx: factorize VLAN
 Ethertype
Date: Sat, 7 May 2016 00:33:44 +0200
Message-ID: <20160506223344.GE2073@lunn.ch>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462571843-14397-16-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>, f@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58754 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758781AbcEFWdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 18:33:47 -0400
Content-Disposition: inline
In-Reply-To: <1462571843-14397-16-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 05:57:17PM -0400, Vivien Didelot wrote:
> The 6131 switch models have a Core Tag Type register. Add a
> MV88E6XXX_FLAG_CORE_TAG_TYPE flag and set the VLAN Ethertype to 0x8100
> in the shared setup code if it is present.

Do you have any idea what the core tag is?

   Andrew
