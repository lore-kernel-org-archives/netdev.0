From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:13:58 -0700 (PDT)
Message-ID: <20060928.151358.01288837.davem@davemloft.net>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
	<1159474625.3741.6.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51163
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030277AbWI1WNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:13:55 -0400
To: mchan@broadcom.com
In-Reply-To: <1159474625.3741.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 28 Sep 2006 13:17:04 -0700

> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
> Dumping 64K worth of registers and blinking the LEDs should be
> restricted.  But I have no problem doing these checks in the driver if
> necessary.

Ok I removed PHYS_ID and GREGS from the allowed list.
Any others?
