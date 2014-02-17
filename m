From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
Subject: RE: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 19:20:48 +0000
Message-ID: <D53252F45158EF44B1DF124FDC9AF2A35AD9E21E@FEYNMAN.fokus.fraunhofer.de>
References: <D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
	<20140217.140653.1309552047403078220.davem@davemloft.net>
	<D53252F45158EF44B1DF124FDC9AF2A35AD9E1FB@FEYNMAN.fokus.fraunhofer.de>
 <20140217.141403.291320418395122009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "arend@broadcom.com" <arend@broadcom.com>,
	"sw@simonwunderlich.de" <sw@simonwunderlich.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay06-dus.antispameurope.com ([94.100.134.206]:38490 "EHLO
	mx-relay06-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754389AbaBQTUx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 14:20:53 -0500
In-Reply-To: <20140217.141403.291320418395122009.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see. OK. If that's the proper way to do it, then so be it.  The performance hit should be negligible since to 99% it's all the same etherType.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, February 17, 2014 20:14
> To: Kretschmer, Mathias
> Cc: arend@broadcom.com; sw@simonwunderlich.de;
> netdev@vger.kernel.org; linux-wireless@vger.kernel.org
> Subject: Re: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
> 
> From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
> Date: Mon, 17 Feb 2014 19:11:05 +0000
> 
> > Will take a look. Thx. Need to check if there is also a way to set the
> > protocol number when using TX_RINGs, where we use one send() call to
> > signal the kernel that a bunch of frames (with potentially different
> > protocol numbers) is ready for consumption.
> 
> You will have to make seperate TX_RING sends() for each cluster where the
> protocol changes.
