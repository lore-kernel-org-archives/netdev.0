From: Jeff Garzik <jeff@garzik.org>
Subject: wan/pc300 bug found
Date: Sun, 1 Oct 2006 12:35:59 -0400
Message-ID: <20061001163559.GA8649@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:26093 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1750990AbWJAQgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 12:36:01 -0400
To: pc300@cyclades.com, khc@pm.waw.pl, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following gcc warning indicates a bug:

drivers/net/wan/pc300_drv.c: In function =E2=80=98cpc_open=E2=80=99:
drivers/net/wan/pc300_drv.c:2870: warning: =E2=80=98br=E2=80=99 may be =
used uninitialized in this function

clock_rate_calc() is not checked for a negative return value.

