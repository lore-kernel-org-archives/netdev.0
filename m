From: Jeff Garzik <jeff@garzik.org>
Subject: another ATM bug
Date: Sun, 01 Oct 2006 09:34:54 -0400
Message-ID: <451FC3FE.8000003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:65418 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932175AbWJANe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 09:34:56 -0400
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following warning appears to be real:

drivers/atm/ambassador.c: In function =91amb_open=92:
drivers/atm/ambassador.c:1049: warning: =91tx_rate_bits=92 may be used=20
uninitialized in this function

The variable is accessed before the make_rate() error code is checked,=20
thus accessing an uninit'd value.

	Jeff


