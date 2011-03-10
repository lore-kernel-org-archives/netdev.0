From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Thu, 10 Mar 2011 09:54:33 +0100
Message-ID: <20110310085433.GA11953@xanadu.blop.info>
References: <20110310002458.5a94f563.billfink@mindspring.com>
 <2049243270.17294.1299737824096.JavaMail.root@tahiti.vyatta.com>
 <20110310021751.2f5fb8bc.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Injong Rhee <rhee@ncsu.edu>,
	David Miller <davem@davemloft.net>,
	xiyou wangcong <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org, sangtae ha <sangtae.ha@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:52687 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab1CJJAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 04:00:54 -0500
Content-Disposition: inline
In-Reply-To: <20110310021751.2f5fb8bc.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/11 at 02:17 -0500, Bill Fink wrote:
> On Wed, 9 Mar 2011, Stephen Hemminger wrote:
>=20
> > Bill what is the HZ in your kernel config.
> > I am concerned hystart doesn't work well with HZ=3D100
>=20
> HZ=3D1000
>=20
> But I did have tcp_timestamps disabled.  Should I re-run
> the tests with tcp_timestamps enabled?

I ran my tests with timestamps enabled and HZ=3D250. If you have the
opportunity to run tests in the same config, it would be great. The
HZ=3D250 vs HZ=3D1000 difference could explain why it's working.

However, enabling or disabling timestamps shouldn't make a difference,
since the hystart code doesn't use TCP_CONG_RTT_STAMP.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
