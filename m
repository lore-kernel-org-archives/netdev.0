From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 14:14:03 -0500 (EST)
Message-ID: <20140217.141403.291320418395122009.davem@davemloft.net>
References: <D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
	<20140217.140653.1309552047403078220.davem@davemloft.net>
	<D53252F45158EF44B1DF124FDC9AF2A35AD9E1FB@FEYNMAN.fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arend@broadcom.com, sw@simonwunderlich.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: mathias.kretschmer@fokus.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141AbaBQTOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:14:05 -0500
In-Reply-To: <D53252F45158EF44B1DF124FDC9AF2A35AD9E1FB@FEYNMAN.fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
Date: Mon, 17 Feb 2014 19:11:05 +0000

> Will take a look. Thx. Need to check if there is also a way to set
> the protocol number when using TX_RINGs, where we use one send()
> call to signal the kernel that a bunch of frames (with potentially
> different protocol numbers) is ready for consumption.

You will have to make seperate TX_RING sends() for each cluster where
the protocol changes.
