From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/20] sfc: SFX7101: Remove workaround for bad link
	training
Date: Thu, 29 Jan 2009 19:23:31 +0000
Message-ID: <1233257011.3656.56.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
	 <1233256644.3656.19.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:43005 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575AbZA2TXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:23:32 -0500
In-Reply-To: <1233256644.3656.19.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-29 at 19:17 +0000, Ben Hutchings wrote:
> Early versions of the SFX7101 firmware could complete link training i=
n
> a state where it would not adequately cancel noise (Solarflare bug
> 10750).  We previously worked around this by resetting the PHY after
> seeing many Ethernet CRC errors.  This workaround is unsafe since it
> takes no account of the interval between errors; it also appears to
> be unnecessary with production firmware.  Therefore remove it.

=EF=BB=BFShould actually be attributed as:
=46rom: Steve Hodgson <shodgson@solarflare.com>

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

