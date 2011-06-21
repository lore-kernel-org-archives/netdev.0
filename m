From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 12:42:14 -0600
Message-ID: <BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net> <20110621135558.GB9228@S2101-09.ap.freescale.net>
 <4E00E3D2.6050602@firmworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Mitch Bradley <wmb@firmworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49788 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab1FUSmf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:42:35 -0400
In-Reply-To: <4E00E3D2.6050602@firmworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2011 at 12:32 PM, Mitch Bradley <wmb@firmworks.com> wro=
te:
> I wonder if it makes sense to create a new device node "/linux-device=
s" to express a desired mapping from device nodes to /dev entries? =A0T=
he properties could be the names of device special files and the values=
 the corresponding node phandles.

I've been trying /really/ hard to avoid doing something like that
because a lot of the time the desired Linux dev name is a
implementation detail, and a potentially unstable one at that.  If
Linux requires certain devices to have certain names because that is
how it hooks up clocks (which is the current situation on some
platforms), then I'd rather have Linux encode a lookup of the
preferred name, at least until the that particular implementation
detail goes away.

As for enumerating devices, I don't think this is a Linux-specific
thing.  In this case it is entirely reasonable to want to say /this
node/ is the second serial port, and /that node/ is the third, which
is information needed regardless of the client OS.

g.
