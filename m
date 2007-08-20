From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] spidernet: enable poll() before registering interrupts
Date: Tue, 21 Aug 2007 01:06:48 +0200
Message-ID: <200708210106.49101.arnd@arndb.de>
References: <200707120119.12589.arnd@arndb.de> <20070820222945.GJ4261@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Christian Krafft <krafft@de.ibm.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:52676 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbXHTXG7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 19:06:59 -0400
In-Reply-To: <20070820222945.GJ4261@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 August 2007, Linas Vepstas wrote:
>=20
> An intervening patch changed the init so that the=20
> hardware interrupts aren't enabled until after the
> request_irq, and after the poll_enable(). =A0Thus,
> it seems this pach is no longer needed, right?

Right, the other patch that you already applied is a better fix.

	Arnd <><
