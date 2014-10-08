From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Wed, 8 Oct 2014 11:46:20 +0200
Message-ID: <20141008094620.GA12270@unicorn.suse.cz>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be>
 <20141007.161832.453892039501955243.davem@davemloft.net>
 <20141007203344.GA4748@roeck-us.net>
 <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
 <1412715283.11600.11.camel@localhost>
 <063D6719AE5E284EB5DD2968C1650D6D174C6CA5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	Fabian Frederick <fabf@skynet.be>,
	Guenter Roeck <linux@roeck-us.net>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41522 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495AbaJHJqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 05:46:25 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C6CA5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2014 at 09:10:23AM +0000, David Laight wrote:
> From: Hannes Frederic Sowa
> > I think David's concern was whether if 0 =3D=3D false in all situat=
ions. It
> > is pretty clear that static memory is initialized to 0.
>=20
> I'm not 100% sure about that.
> static pointers may be required to be initialised to NULL.

ISO C 99 says:

  If an object that has static storage duration is not initialized
  explicitly, then:
  - if it has pointer type, it is initialized to a null pointer;
  - if it has arithmetic type, it is initialized to (positive or
    unsigned) zero;
  - if it is an aggregate, every member is initialized (recursively)
    according to these rules;
  - if it is a union, the first named member is initialized
    (recursively) according to these rules.

Michal Kube=E8ek
