From: "Roland Kletzing" <devzero@web.de>
Subject: send/receive data via eth0/1 external loop ?
Date: Sat, 12 Nov 2011 01:47:13 +0100 (CET)
Message-ID: <104297899.1282710.1321058833510.JavaMail.fmail@mwmweb017>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate05.web.de ([217.72.192.243]:53376 "EHLO
	fmmailgate05.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227Ab1KLAxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 19:53:44 -0500
Received: from web.de
	by fmmailgate05.web.de (Postfix) with ESMTP id 8129B67938B5
	for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 01:47:13 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
i`m searching for a while now, but i did not find a solution, so forgive when
i`m (as a user) asking for expert help here.

I want to do some network stress/burn-in and quality/reliability testing,
i.e. i want to send/receive large amounts of data trough the systems network
interfaces without the need of hogging the net or other systems.

so, that test should run "loopback", i.e. connecting eth0+1 via crossover cable
or via locally attached switch. I don`t want to use a second system for that.

testing at ip/tcp level would be favourable , but raw eth level would be also fine.

But how ?
What appears simple on a first view, seems to be difficult.... :(

All i came across is this report:
http://www.zyztematik.com/?p=10
and this description of a patch:
http://www.ssi.bg/~ja/send-to-self.txt

Does somebody know a proper way of achieving this without patching the
kernel ?

regards
Roland
___________________________________________________________
SMS schreiben mit WEB.DE FreeMail - einfach, schnell und
kostenguenstig. Jetzt gleich testen! http://f.web.de/?mc=021192
