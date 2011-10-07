From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: Old Mobile-IP code and modern Linux
Date: Fri, 7 Oct 2011 06:27:24 -0700 (PDT)
Message-ID: <1317994044.53022.YahooMailNeo@web161201.mail.bf1.yahoo.com>
Reply-To: Joerg Pommnitz <pommnitz@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm30.bullet.mail.bf1.yahoo.com ([98.139.212.189]:37981 "HELO
	nm30.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752532Ab1JGNeL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 09:34:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
I'm trying to run the old dynamics Mobile IP implementation (see http:/=
/dynamics.sourceforge.net/) on a modern Linux kernel (Fedora 15 2.6.40 =
aka 3.0).
There seems to be a problem in the communication between a mobile node =
and the foreign agent. The mobile node sends UDP packets with a source =
address from its own home network to the discovered address of the FA. =
Unfortunately the FA never sees these packets. It seems that packets wi=
th an unexpected source address will be discarded (ingress filtering?).=
 Is there a way to disable this behavior? What is the right way to impl=
ement MobileIP on a recent Linux kernel?

Thanks in advance
=A0 Joerg
