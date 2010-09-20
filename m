From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 12:12:32 +0000
Message-ID: <20100920121232.GA9931@ff.dom.local>
References: <1283852248.2338.160.camel@edumazet-laptop> <20100910.125449.235704956.davem@davemloft.net> <20100911123140.GA1939@del.dom.local> <20100919.171725.245378386.davem@davemloft.net> <20100920072149.GA6353@ff.dom.local> <1284973320.3420.49.camel@edumazet-laptop> <20100920091425.GA8381@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61866 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755965Ab0ITMMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:12:35 -0400
Received: by bwz11 with SMTP id 11so4163416bwz.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 05:12:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100920091425.GA8381@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 20, 2010 at 09:14:25AM +0000, Jarek Poplawski wrote:
> On Mon, Sep 20, 2010 at 11:02:00AM +0200, Eric Dumazet wrote:
> > Le lundi 20 septembre 2010 ?? 07:21 +0000, Jarek Poplawski a =E9cri=
t :
> > > Btw, I wonder what is the exact reason we can't use only
> > > NET_SKBUFF_DATA_USES_OFFSET?
> >=20
> > I see no real reason.
> >=20
> > On 32bit arches, it might be faster to manipulate pointers, and not
> > 'base+offset' values.
>=20
> The only reason is code readability and maintenance. Did anybody chec=
k
> how much faster?

Hmm... I probably misread your reasoning. So, if no real reason,
really, how about turning this NET_SKBUFF_DATA_USES_OFFSET on
unconditionally in net-next, until somebody spots the difference?

Jarek P.
