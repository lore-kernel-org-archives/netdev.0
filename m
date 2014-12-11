From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [net] gre: fix the inner mac header in nbma gre tunnels xmit
 path
Date: Thu, 11 Dec 2014 21:44:56 +0200
Message-ID: <20141211214456.7cc621e4@vostro>
References: <CA+mtBx-WsgMRAYDUaPiVaBt43cRx7tb-0hRJ+6Eao8vjd3j8aQ@mail.gmail.com>
	<1418282079-30245-1-git-send-email-timo.teras@iki.fi>
	<20141211.143627.1516156524809595238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com,
	alexander.h.duyck@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:63747 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932848AbaLKTpI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:45:08 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so4780537lbv.0
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 11:45:06 -0800 (PST)
In-Reply-To: <20141211.143627.1516156524809595238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2014 14:36:27 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Date: Thu, 11 Dec 2014 09:14:39 +0200
>=20
> > @@ -266,6 +262,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff
> > *skb,
> >  		 * to gre header.
> >  		 */
> >  		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
> > +		skb_reset_mac_header(mac);
>=20
> Please explain to me how this compiles, let alone be functionally
> tested.

Sorry. I made the change twice; once on the build box. And again on my
git checkout on work station. Must've been on seriously coffee deprived
state.

Should be obviously:
+		skb_reset_mac_header(skb);

Is there other comments on it?

Or shall I resend?
