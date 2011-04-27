From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Wed, 27 Apr 2011 18:30:09 +0200
Message-ID: <1303921809.3166.90.camel@edumazet-laptop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
	 <1303834864.3358.58.camel@edumazet-laptop>
	 <4DB83A60.5040102@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Steve Hodgson <shodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64502 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099Ab1D0QaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 12:30:14 -0400
Received: by wya21 with SMTP id 21so1394625wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 09:30:13 -0700 (PDT)
In-Reply-To: <4DB83A60.5040102@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 16:46 +0100, Steve Hodgson a =C3=A9cri=
t :
> On 04/27/2011 04:24 PM, Eric Dumazet wrote:
> > Le mardi 26 avril 2011 =C3=A0 09:12 -0700, Rose, Gregory V a =C3=A9=
crit :
> >
> >> I'm fine with however you folks want to approach this, just give m=
e some direction.
> >
> > I would just try following patch :
> >
>=20
> This allows the sfc driver to use 102 VFs, up from the current limit =
of=20
> 45 VFs.
>=20
> It's unfortunate that this patch isn't sufficient to allow all 127 VF=
s=20
> to be used, but whilst we wait for a new netlink api this is an=20
> improvement worth having.
>=20

netlink recvmsg() supports MSG_PEEK so user would get the needed size o=
f
its buffer before calling the real recvmsg()

big blobs could be attached as skb fragments (up to 64Kbytes), but do w=
e
really want this...



