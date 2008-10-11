From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Sat, 11 Oct 2008 10:38:54 -0300
Message-ID: <48f0ac73.050cc00a.02ca.437f@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
	<alpine.LFD.2.00.0810082154420.3237@apollo>
	<Pine.LNX.4.64.0810082329250.7599@wrl-59.cs.helsinki.fi>
	<48eed827.060ec00a.1389.ffffb4e3@mx.google.com>
	<Pine.LNX.4.64.0810111121050.18685@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:27256 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbYJKNjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 09:39:02 -0400
Received: by qw-out-2122.google.com with SMTP id 3so287367qwe.37
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 06:39:00 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810111121050.18685@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Oct 2008 11:27:50 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> This time there isn't any listening socket with queue to be accepted,=
 not=20
> connections. So it's not exactly the same situation on the server, I'=
m=20
> sort of thinking that the accept() stuff we found earlier is just=20
> coincidence, I guess it could as well hang somewhere else on other
> times.

	Ok, this was with 2.6.27-rc8. Now I'm using the final 2.6.27
version and, at least until now, no stall happened. 2.6.27 seems much
better than 2.6.25 and 2.6.26.

--=20
