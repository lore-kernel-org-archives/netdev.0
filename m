From: Tino Keitel <tino.keitel@tikei.de>
Subject: wake on LAN with sky2
Date: Tue, 12 Dec 2006 21:27:20 +0100
Message-ID: <20061212202720.GA12047@thinkpad.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:54693 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396AbWLLU1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 15:27:21 -0500
Received: from thinkpad.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id ADD4D25C3E0
	for <netdev@vger.kernel.org>; Tue, 12 Dec 2006 21:27:19 +0100 (CET)
Received: from scorpion by thinkpad.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1GuEDh-0003Ba-6c
	for netdev@vger.kernel.org; Tue, 12 Dec 2006 21:27:21 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

I just tried the sk98lin driver version 8.41.2.3 and was happy that it
seems to support wake on LAN with the Marvell 88E8053 PCIe chip.
However, after resume from suspend to RAM, the machine hangs. As it
doesn't hang with sky2, it looks like this particular driver breaks
suspend to RAM. ($%&?#!!!)

A quick look into sk98lin_suspend() shows that there is not much stuff
in there. Am I right that I just have to port that stuff to sky2? The
affected file skge.c is licenced under the GPL v2 or later.

Regards,
Tino
