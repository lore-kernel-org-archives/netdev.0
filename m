From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Fri, 20 Nov 2009 07:49:19 +0100
Message-ID: <4B063BEF.4000405@gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>	 <87hbt0kaae.fsf@basil.nowhere.org>	 <65634d660911160902t677a4fb4r71602cb0d10f1cce@mail.gmail.com>	 <20091119100805.GA22938@basil.fritz.box> <65634d660911192241q30a3928bg44854fc929dae218@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54099 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbZKTGtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 01:49:21 -0500
In-Reply-To: <65634d660911192241q30a3928bg44854fc929dae218@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
>=20
> So is send_remote_softirq also broken according to this?

I found this function not usable as is, anyway.
I tried to use it for XPS but failed.

Before calling it, we must put the work in a remote queue,
but if work has to be done by current cpu, we cannot remove this
work to put it in our queue. (We dont have a status from send_remote_so=
ftirq())


