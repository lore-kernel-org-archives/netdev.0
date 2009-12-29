From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Mon, 28 Dec 2009 19:24:51 -0500
Message-ID: <1262046291.8998.6.camel@obelisk.thedillows.org>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
	 <20091228195053.GB18422@hmsreliant.think-freely.org>
	 <20091228213114.GA24285@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com, nhorman@redhat.com
To: =?ISO-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:50255 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbZL2AY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 19:24:58 -0500
In-Reply-To: <20091228213114.GA24285@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-12-28 at 22:31 +0100, Fran=C3=A7ois romieu wrote:
> (I'm back)
>=20
> The Mon, Dec 28, 2009 at 02:50:53PM -0500, Neil Horman wrote :
> [...]
> I doubt that we will be able to allocate that much memory reliably fo=
r long.
>=20
> I'd rather go for static buffers + copy (+ src mac address of our new=
 friend).

The driver doesn't support fragmented receives, but it seems like the H=
W
does -- is this known to work on the different revisions? Or
alternatively, is it known to be broken on any of them? It seems like i=
t
would be preferable to implement this and use RxMaxSize to tell the NIC
how big the allocated buffer fragments are.

Or I'm misreading the capabilities of the NIC?

In any event, I'm probably not going to have time to write/test it on
the HW I have anytime soon, so perhaps the static buffers/copy is the
safest option for now, albeit non-optimal.

Dave

