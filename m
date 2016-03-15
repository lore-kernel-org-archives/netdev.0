From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 14 Mar 2016 20:40:02 -0400
Message-ID: <20160314204002.13c7eddd064910bced47b5d7@mindspring.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	<1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
	<1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
	<CAK6E8=eXH1HEXEWiAnUTT65i9=M=j1W1v3MQFSxvk2xF_TNLZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:59168 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754529AbcCOAqp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 20:46:45 -0400
In-Reply-To: <CAK6E8=eXH1HEXEWiAnUTT65i9=M=j1W1v3MQFSxvk2xF_TNLZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Mar 2016, Yuchung Cheng wrote:

> On Thu, Mar 3, 2016 at 10:06 AM, Bendik R=F8nning Opstad
> <bro.devel@gmail.com> wrote:
> >
> > Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reduc=
ing
> > the latency for applications sending time-dependent data.
=2E..
> > diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation=
/networking/ip-sysctl.txt
> > index 6a92b15..8f3f3bf 100644
> > --- a/Documentation/networking/ip-sysctl.txt
> > +++ b/Documentation/networking/ip-sysctl.txt
> > @@ -716,6 +716,21 @@ tcp_thin_dpifl_itt_lower_bound - INTEGER
> >         calculated, which is used to classify whether a stream is t=
hin.
> >         Default: 10000
> >
> > +tcp_rdb - BOOLEAN
> > +       Enable RDB for all new TCP connections.
>   Please describe RDB briefly, perhaps with a pointer to your paper.
>    I suggest have three level of controls:
>    0: disable RDB completely
>    1: enable indiv. thin-stream conn. to use RDB via TCP_RDB socket
> options
>    2: enable RDB on all thin-stream conn. by default
>=20
>    currently it only provides mode 1 and 2. but there may be cases wh=
ere
>    the administrator wants to disallow it (e.g., broken middle-boxes)=
=2E
>=20
> > +       Default: 0

A per route setting to enable or disable tcp_rdb, overriding
the global setting, could also be useful to the administrator.
Just a suggestion for potential followup work.

					-Bill
