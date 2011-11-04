From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: iproute2 neighboring
Date: Fri, 4 Nov 2011 08:54:04 -0700 (PDT)
Message-ID: <1320422044.81742.YahooMailNeo@web126019.mail.ne1.yahoo.com>
References: <CAGXs5wUEiS-vpdsCDoyva2Vg9XKBmbJgoPVOXUXD0u9+PzXH=w@mail.gmail.com> <OFD3A98142.1EDCCB6F-ON8825793E.0055C070-8825793E.0056A45E@us.ibm.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>,
	Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm20-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.21]:25819 "HELO
	nm20-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755554Ab1KDPyG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 11:54:06 -0400
In-Reply-To: <OFD3A98142.1EDCCB6F-ON8825793E.0055C070-8825793E.0056A45E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





----- Original Message -----
> From: David Stevens <dlstevens@us.ibm.com>
> To: Kevin Wilson <wkevils@gmail.com>
> Cc: netdev@vger.kernel.org; netdev-owner@vger.kernel.org
> Sent: Friday, November 4, 2011 4:46 PM
> Subject: Re: iproute2 neighboring
>=20
>>  From: Kevin Wilson <wkevils@gmail.com>
>=20
>>  Hi,
>>  It seems to me that "ip -6 neigh show" does not show multicast=20
> entries=20
> from
>>  IPv6 neighboring=A0 table. Is there a reason for this ?
>=20
> Multicast memberships aren't in the neighbor table. The
> neighbor table is for translating protocol addresses to
> MAC addresses and that translation is fixed for multicast
> destinations.
>=20
> You can see group memberships with "netstat -g". There are also
> some data in /proc/net/{dev_mcast,igmp6,mcfilter6} depending on
> what you're looking for.
>=20
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 +-DLS

Hi,

You can also see group memberships with "ip m".

=46ran=E7ois-Xavier
