From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 2 Sep 2010 12:00:09 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D0670D1@nsmail.netscout.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com><1283356463.2556.351.camel@edumazet-laptop><AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com><20100901.183251.106803238.davem@davemloft.net> <20100901184802.5a79cf9f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <therbert@google.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og114.obsmtp.com ([64.18.1.33]:36661 "HELO
	exprod6og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755872Ab0IBQAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:00:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100901184802.5a79cf9f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: September 01, 2010 9:48 PM
> To: David Miller
> Cc: therbert@google.com; eric.dumazet@gmail.com;
netdev@vger.kernel.org
> Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
 
> Plus it needs to work with scheduler (not fight it).  All this doesn't
> work very well if process keeps bouncing away from its resources.
> 

userland folks who actually try to exploit the MQ/MSIX-ness will almost
always pin down their high-prio[or subset of] threads/processes.

Chetan Loke
 

