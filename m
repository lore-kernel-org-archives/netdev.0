From: "Jonathan Hutchins" <hutchins@tarcanfel.org>
Subject: tiacx100 problem
Date: Thu, 19 Apr 2007 15:30:19 -0500 (CDT)
Message-ID: <34104.192.168.76.5.1177014619.squirrel@mercury>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64-151-34-11.dyn.everestkc.net ([64.151.34.11]:1836 "EHLO
	mercury.tarcanfel.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422667AbXDSUsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:48:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe the following error message is from the tiacx driver, and is not
related to the firmware:
"unknown chip and EEPROM version combination (ACX100, v0), don't know how
to parse config options yet. Please report"

This is for an SMC2435W, part number 99-012084-036.  While it appears to
load, the card registers as eth1 instead of wlan0, and iwlist reports
"eth1      Interface doesn't support scanning."  iwconfig will not
actually set the essid for the card.

Running Mandriva 2007.1, kernel 2.6.17-5mdv on a Toshiba Satellite A15-S129.

This card worked under Mandriva 9.1.

The firmware source page listed on sourceforge's site is no longer available.
