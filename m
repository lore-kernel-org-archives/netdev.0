From: Eliezer Tamir <eliezer@tamir.org.il>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 18:44:14 +0300
Message-ID: <g2ye8f3c3211004280844s9291cad9jab53e0bbd983c329@mail.gmail.com>
References: <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>
	 <20100427.151937.62344362.davem@davemloft.net>
	 <1272460455.30392.24.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, vladz@broadcom.com,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"xiaosuo@gmail.com" <xiaosuo@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"therbert@google.com" <therbert@google.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:39322 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab0D1PoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 11:44:17 -0400
Received: by ewy20 with SMTP id 20so4839110ewy.1
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 08:44:14 -0700 (PDT)
In-Reply-To: <1272460455.30392.24.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 4:14 PM, Eilon Greenstein <eilong@broadcom.com> wrote:
>
> On Tue, 2010-04-27 at 15:19 -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 28 Apr 2010 00:18:13 +0200
> >
> > > [PATCH net-next-2.6] bnx2x: Remove two prefetch()
> > >
> > > 1) Even on 64bit arches, sizeof(struct sk_buff) < 256
> > > 2) No need to prefetch same pointer twice.
> > >
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > CC: Eilon Greenstein <eilong@broadcom.com>
> >
> > Eilon please review and ACK/NACK
>
> Vlad ran few benchmarks, and we couldn't find any justification for
> those prefetch calls. After consulting with Eliezer Tamir (the original
> author) we are glad to Ack this patch.
>
> Thanks Eric!
> Acked-by: <eilong@broadcom.com>
>
>
Normally, I would not have said anything but since Eilon asked.
Acked-by: <eliezer@tamir.org.il>
(this time in plain text)
