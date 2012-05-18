From: Timur Tabi <b04825@freescale.com>
Subject: Re: [PATCH v6 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Fri, 18 May 2012 17:09:10 -0500
Message-ID: <4FB6C886.3050105@freescale.com>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com> <CAOZdJXWVCu+aNxcQRkcSSDsWWxnn8B9X5Y6=8oVgFwJ9SZTTGQ@mail.gmail.com> <4FB6C728.3090507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:58829
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967321Ab2ERWJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 18:09:33 -0400
In-Reply-To: <4FB6C728.3090507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Daney wrote:
>> > I'm not sure what the "parent" MDIO bus node is supposed to represent.
>> >   Is that that device that actually controls the muxing hardware

> No.  It is the device that implements the master 802.3 clause {22,45} 
> MDIO Station Management (STA) protocol.

Ah, I think I get it.  It is *the* MDIO node that would normally exist if
muxing we're necessary on the board.  From the looks of it, that node
would look exactly the same if you didn't need muxing?

-- 
Timur Tabi
Linux kernel developer at Freescale
