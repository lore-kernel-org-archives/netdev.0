From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile build
 warning
Date: Sat, 3 Nov 2012 23:48:32 +0100
Message-ID: <20121103224832.GA24262@gmail.com>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
 <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
 <1351982441.1434.5.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:33879 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab2KCWsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 18:48:36 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1800933eaa.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 15:48:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1351982441.1434.5.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Nov 2012, Paul Bolle wrote:

> On Sat, 2012-11-03 at 23:02 +0100, Lee Jones wrote:
> > This patch fixes:
> > drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=80=
=99:
> > drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=
=80=98s=E2=80=99 [-Wunused-variable]
>=20
> Did you have CONFIG_NETDEVICES not set in this build?

Ah yes, I see it. The function went down further than I thought
it did. So the real fix is to ensure 's' is defined inside of
some ifdef CONFIG_NETDEVICES guards.=20

I'll fix up and resend. Will likely be tomorrow now, as it's
fast approaching midnight here.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
