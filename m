From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Fri, 11 Mar 2011 06:59:18 +0100
Message-ID: <20110311055918.GA10228@xanadu.blop.info>
References: <20110308093215.GA23842@xanadu.blop.info>
 <20110310152848.7b515511@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:58693 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597Ab1CKGCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 01:02:23 -0500
Content-Disposition: inline
In-Reply-To: <20110310152848.7b515511@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/11 at 15:28 -0800, Stephen Hemminger wrote:
> On Tue, 8 Mar 2011 10:32:15 +0100
> Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
>=20
> > CUBIC Hystart uses two heuristics to exit slow start earlier, befor=
e
> > losses start to occur. Unfortunately, it tends to exit slow start f=
ar too
> > early, causing poor performance since convergence to the optimal cw=
nd is
> > then very slow. This was reported in
> > http://permalink.gmane.org/gmane.linux.network/188169 and
> > https://partner-bugzilla.redhat.com/show_bug.cgi?id=3D616985
>=20
> Ignore the RHEL bug. RHEL 5 ships with TCP BIC (not CUBIC) by default=
=2E
> There are many research papers which show that BIC is too aggressive,
> and not fair.

According to the bug report, the server is running RHEL6 (with CUBIC an=
d
Hystart), it's the client that is running RHEL5.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
