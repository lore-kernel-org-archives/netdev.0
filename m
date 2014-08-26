From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor resiliency
 queue
Date: Tue, 26 Aug 2014 16:48:16 +0200
Message-ID: <20140826144816.GD24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1409043477-22761-1-git-send-email-erik.hugne@ericsson.com>
 <1409043477-22761-2-git-send-email-erik.hugne@ericsson.com>
 <20140826143245.GC24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
 <A2BAEFC30C8FD34388F02C9B3121859D1C2BF752@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ying.xue@windriver.com" <ying.xue@windriver.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:60043 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758399AbaHZOsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:48:18 -0400
Content-Disposition: inline
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C2BF752@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 04:44:34PM +0200, Jon Maloy wrote:
> (netdev removed from receiver list)
>=20
> > -----Original Message-----
> > From: Erik Hugne
> > Sent: August-26-14 10:33 AM
> > To: Jon Maloy; ying.xue@windriver.com; Richard Alpe;
> > netdev@vger.kernel.org
> > Cc: tipc-discussion@lists.sourceforge.net
> > Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor res=
iliency
> > queue
> >=20
> > if (e->expiry > now) should in fact be
> > if (time_after(e->expiry, now) to handle timer wraps correctly.
> >=20
> > Thanks Niklas S=F6derlund for pointing this out.
> >=20
> > v2 removed from patchwork
> >=20
> > //E
>=20
> Also, don't use the version label an comment when you send this
> to David. This has only relevance to us who are reviewing the
> series. (I assume it was  a mistake)

No, this is in the general guidelines for submitting patches section 15=
=2E
https://www.kernel.org/doc/Documentation/SubmittingPatches

//E
