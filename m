From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 14:54:28 +0200
Message-ID: <20080531125428.GA22111@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu> <20080531060947.GA26441@elte.hu> <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:35077 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbYEaMzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 08:55:11 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> > Btw, does your distcc perhaps happen enable TCP_DEFER_ACCEPT (there=
=20
> > were some post 2.6.25 changes into it)?
>=20
> Hmm, if so, please try this revert below (I hope I got everything tha=
t=20
> is related there, gitk is currently broken for me so that viewing man=
y=20
> commits quickly is a pain, so I might have accidently missed=20
> something)...

what is the easiest way to figure out whether my version of distcc=20
enables TCP_DEFER_ACCEPT?

	Ingo
