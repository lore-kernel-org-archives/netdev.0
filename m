From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH v2 net-next 2/2] tipc: add name distributor resiliency
 queue
Date: Tue, 26 Aug 2014 14:55:44 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2BF77C@eusaamb103.ericsson.se>
References: <1409043477-22761-1-git-send-email-erik.hugne@ericsson.com>
 <1409043477-22761-2-git-send-email-erik.hugne@ericsson.com>
 <20140826143245.GC24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
 <A2BAEFC30C8FD34388F02C9B3121859D1C2BF752@eusaamb103.ericsson.se>
 <20140826144816.GD24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ying.xue@windriver.com" <ying.xue@windriver.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:52821 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbaHZOzq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:55:46 -0400
In-Reply-To: <20140826144816.GD24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Erik Hugne
> Sent: August-26-14 10:48 AM
> To: Jon Maloy
> Cc: ying.xue@windriver.com; Richard Alpe; netdev@vger.kernel.org; tip=
c-
> discussion@lists.sourceforge.net
> Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor resil=
iency
> queue
>=20
> On Tue, Aug 26, 2014 at 04:44:34PM +0200, Jon Maloy wrote:
> > (netdev removed from receiver list)
> >
> > > -----Original Message-----
> > > From: Erik Hugne
> > > Sent: August-26-14 10:33 AM
> > > To: Jon Maloy; ying.xue@windriver.com; Richard Alpe;
> > > netdev@vger.kernel.org
> > > Cc: tipc-discussion@lists.sourceforge.net
> > > Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor
> > > resiliency queue
> > >
> > > if (e->expiry > now) should in fact be if (time_after(e->expiry,
> > > now) to handle timer wraps correctly.
> > >
> > > Thanks Niklas S=F6derlund for pointing this out.
> > >
> > > v2 removed from patchwork
> > >
> > > //E
> >
> > Also, don't use the version label an comment when you send this to
> > David. This has only relevance to us who are reviewing the series. =
(I
> > assume it was  a mistake)
>=20
> No, this is in the general guidelines for submitting patches section =
15.
> https://www.kernel.org/doc/Documentation/SubmittingPatches
>=20
> //E

Ok. I missed that this actually was the second version you sent to
netdev.  What I meant was the versioning we are using during our
own, internal discussions at tipc-discussion. This certainly has no
relevance for David & co.

Regards
///jon
