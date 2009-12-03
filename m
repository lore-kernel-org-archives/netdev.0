From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 4/5] bnx2: Read firmware version from VPD.
Date: Thu, 3 Dec 2009 13:43:48 -0800
Message-ID: <1259876628.8991.7.camel@HP1>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
 <1259869595-6450-4-git-send-email-mchan@broadcom.com>
 <1259871433.2780.42.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2237 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbZLCVxq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:53:46 -0500
In-Reply-To: <1259871433.2780.42.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-12-03 at 12:17 -0800, Ben Hutchings wrote:
> > +     for (i =3D 0; i < 128; i +=3D 4) {
> > +             data[i] =3D data[i + 131];
> > +             data[i + 1] =3D data[i + 130];
> > +             data[i + 2] =3D data[i + 129];
> > +             data[i + 3] =3D data[i + 128];
> > +     }
>=20
> Is this correct for both big-endian and little-endian architectures?

Yes, the nvram function returns data in a byte-stream that is the same
in little or big endian.

> =EF=BB=BFPerhaps these VPD tag values should go in pci_regs.h.

How about we do this later and convert other drivers at the same time?

I will send out a fixup patch shortly incorporating all your other
suggestions.  Thanks.




