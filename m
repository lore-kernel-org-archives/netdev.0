From: gionnico <gionnico@email.it>
Subject: possible regression: sis900 fast ethernet doesn't work anymore with 2.6.28
Date: Sun, 4 Jan 2009 03:14:12 +0100
Message-ID: <2c516d98188897b789f709fbe4166cc8@83.147.85.34>
Reply-To: gionnico <gionnico@email.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out05.email.it ([212.97.34.16]:44409 "EHLO
	smtp-out05.email.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbZADCsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2009 21:48:12 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp-out05.email.it (Postfix) with ESMTP id CD9894004
	for <netdev@vger.kernel.org>; Sun,  4 Jan 2009 03:14:12 +0100 (CET)
Received: from smtp-out05.email.it ([127.0.0.1])
	by localhost (smtp-out05.email.it [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 357MhxnaTvDk for <netdev@vger.kernel.org>;
	Sun,  4 Jan 2009 03:14:12 +0100 (CET)
Received: from 83.147.85.34 (wm7.email.it [212.97.34.50])
	by smtp-out05.email.it (Postfix) with ESMTP id AA8B64002
	for <netdev@vger.kernel.org>; Sun,  4 Jan 2009 03:14:12 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a headless system.
It's a testing x86.

It has got a "Silicon Integrated Systems [SiS] SiS900 PCI Fast Ethernet (rev
90)" ethernet controller.
It's always worked fine with 2.6.27. I've updated to
2.6.28 .. (make silentoldconfig) and now networking doesn't work anymore.

dhcpcd waits and then assigns "an old ip from some assumed cache file" (that
has nothing to do with my 192.168.* LAN but is something else like 167 or
something)

Also manual configuration doesn't work anymore. On the other hand the same
static config works if I load the 2.6.27 kernel.

net.eth0 is recognized also by 2.6.28, though.
And it is fired up at bootup, also.

Indeed the full-duplex link appears in the 2.6.28 kernel log (as it appeared
in
2.6.27).
 
 --
 Caselle da 1GB, trasmetti allegati fino a 3GB e in piu' IMAP, POP3 e SMTP
autenticato? GRATIS solo con Email.it: http://www.email.it/f
 
 Sponsor:
 Incontri con Meetic : Primo sito d'incontri in Europa - Milioni di single !
 Clicca qui: http://adv.email.it/cgi-bin/foclick.cgi?mid=8293&d=20090104


