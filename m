From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming
 up)
Date: Tue, 15 Mar 2011 20:56:59 +0100
Message-ID: <1300219019.2565.1.camel@edumazet-laptop>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	 <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
	 <1300164166.2649.70.camel@edumazet-laptop>
	 <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org>
	 <1300169749.2649.142.camel@edumazet-laptop>
	 <3D05C1F1-B75E-426B-8267-6DB5323A839D@gmail.com>
	 <1300213714.2927.37.camel@edumazet-laptop>
	 <7CFAAB08-8A30-4569-8825-64121D43EA77@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jonathan Morton <chromatix99@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61156 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833Ab1COT5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:57:04 -0400
Received: by fxm17 with SMTP id 17so964267fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 12:57:02 -0700 (PDT)
In-Reply-To: <7CFAAB08-8A30-4569-8825-64121D43EA77@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 mars 2011 =C3=A0 20:37 +0200, Jonathan Morton a =C3=A9crit =
:
> On 15 Mar, 2011, at 8:28 pm, Eric Dumazet wrote:
>=20
> >>> band 0 : high priority packets (like now)
> >>> band 1 : (old band 1, ECN capable flows)
> >>> band 2 : (old band 1, no ECN flows)
> >>> band 3 : low priority packets (old band 2)
> >>=20
> >> This seems good to me.  It would provide a concrete (if minor) ent=
icement to turn ECN on.
> >=20
> > Here is a patch to implement that, on top of net-next-2.6 git tree
>=20
> Does this take both ECN bits into account?  The ECT(0), ECT(1) and EC=
E codepoints all need to be recognised equally.

This is done in a different layer, as already explained.

Current linux code ignores low order bit when doing TOS -> skb->priorit=
y
mapping.



