From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Wed, 22 Oct 2008 17:05:17 -0700
Message-ID: <20081022170517.051d766f@extreme>
References: <20081020190922.7dd6510a@extreme>
	<20081020.221857.209830018.davem@davemloft.net>
	<48FE34AF.8050508@hp.com>
	<48FE386F.8090706@cosmosbay.com>
	<20081021133811.68bd5ce1@extreme>
	<48FFBE19.7010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60325 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbYJWAFT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 20:05:19 -0400
In-Reply-To: <48FFBE19.7010803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2008 16:58:17 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 21 Oct 2008 22:15:43 +0200
> > Eric Dumazet <dada1@cosmosbay.com> wrote:
> >=20
> >=20
> >>Rick Jones a =C3=A9crit :
> >>> I've not had a good emily litella moment all day so I'll ask - is
> >>> there really that much in the way of suitable skb's which are
> >>> completely free after transmit completion?
> >>
> >> Or, if we take another way, say a VOIP RTP machine sends and
> >> receive 20.000 packets per second, each being 200 bytes long, are
> >> transmited packets correctly sized at sendto() time to be
> >> candidates for recycling ?
> >=20
> > No. Most locally generate packets aren't going to be right size
> > because they will be too small, cloned or fragmented.  It really on=
ly
> > helps when forwarding.
>=20
> So we have a bit of "tension" between the desires of an end host vs=20
> those of a router right?
>=20
> rick jones

Not tension, just means on end host this optimization does nothing.
