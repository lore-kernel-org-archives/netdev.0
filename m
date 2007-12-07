From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Thu, 6 Dec 2007 19:27:21 -0800
Message-ID: <aa7d2c6d0712061927g2e6f1679o8b05f76d723c0c76@mail.gmail.com>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	 <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
	 <474E0B33.2060108@linux-foundation.org>
	 <001b01c83248$604f4120$20edc360$@edu>
	 <20071203145207.40e4ac57@freepuppy.rosehill>
	 <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
	 <002f01c83608$8a2fb600$9e8f2200$@edu>
	 <20071203163217.27e4df3f@freepuppy.rosehill>
	 <aa7d2c6d0712031723t314da471n8f033e8d1b523e1a@mail.gmail.com>
	 <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	"Tom Quetchenbach" <quetchen@caltech.edu>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:4970 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbXLGD1W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 22:27:22 -0500
Received: by py-out-1112.google.com with SMTP id u77so1107024pyb
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 19:27:21 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings Ilpo,

On 04/12/2007, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 3 Dec 2007, Lachlan Andrew wrote:
> >
> > When SACK is active, the per-packet processing becomes more involve=
d,
> > tracking the list of lost/SACKed packets.  This causes a CPU spike
> > just after a loss, which increases the RTTs, at least in my
> > experience.
>
> I suspect that as long as old code was able to use hint, it wasn't do=
ing
> that bad. But it was seriously lacking ability to take advantage of s=
ack
> processing hint when e.g., a new hole appeared, or cumulative ACK arr=
ived.
>
> ...Code available in net-2.6.25 might cure those.

We had been using one of your earlier patches, and still had the
problem.  I think you've cured the problem with SACK itself, but there
still seems to be something taking a lot of CPU while recovering from
the loss.  It is possible that it was to do with  web100  which we
have also been running, but I cut out most of the statistics from that
and still had problems.

Cheers,
Lachlan

--=20
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
