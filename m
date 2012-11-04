From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile
 build warning
Date: Sun, 04 Nov 2012 11:14:51 +0100
Message-ID: <1352024091.1434.17.camel@x61.thuisdomein>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
	 <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
	 <1351982441.1434.5.camel@x61.thuisdomein>
	 <20121103224832.GA24262@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews09.kpnxchange.com ([213.75.39.14]:58908 "EHLO
	cpsmtpb-ews09.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab2KDKOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 05:14:53 -0500
In-Reply-To: <20121103224832.GA24262@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-03 at 23:48 +0100, Lee Jones wrote:
> On Sat, 03 Nov 2012, Paul Bolle wrote:
> > On Sat, 2012-11-03 at 23:02 +0100, Lee Jones wrote:
> > > This patch fixes:
> > > drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=
=80=99:
> > > drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=
=80=98s=E2=80=99 [-Wunused-variable]
> >=20
> > Did you have CONFIG_NETDEVICES not set in this build?
>=20
> Ah yes, I see it. The function went down further than I thought
> it did. So the real fix is to ensure 's' is defined inside of
> some ifdef CONFIG_NETDEVICES guards.=20

What puzzles me is that we only find these "#ifdef CONFIG_NETDEVICES"
guards in this file and not in isdn_net.c, were all the ioctl commands
guarded that way seem to be calling into. On first glance that doesn't
make much sense.

(Actually the idea of having ISDN without NETDEVICES is a bit puzzling
too. But there are too many parts of the isdn subsystem that I'm
unfamiliar with to say whether that can make sense.)


Paul Bolle
