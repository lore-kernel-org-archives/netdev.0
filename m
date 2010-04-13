From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 19:22:32 +0200
Message-ID: <4BC4A858.9010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:60442 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab0DMRWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 13:22:37 -0400
Received: by wwb34 with SMTP id 34so168480wwb.19
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 10:22:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stephen mulcahy  wrote:

> running Hadoop[1] TeraSort[2] but I haven't identified a simpler=20
> reproducer. I tried to recreate this with iperf and ping -f but neith=
er=20
> helped - it may be that the problem only occurs when systems are pass=
ing=20
> large amounts of traffic and have very high cpu utilisation (when=20

Did you try ISIC(IP Stack Integrity Checker)[1] tools ?

Net-drivers usually break running these tools.


[1] http://isic.sf.net needs libnet[2]
[2] http://github.com/sam-github/libnet

--=20
=ABAll=E1 muevan feroz guerra, ciegos reyes por un palmo m=E1s de tierr=
a;
que yo aqu=ED tengo por m=EDo cuanto abarca el mar brav=EDo, a quien na=
die
impuso leyes. Y no hay playa, sea cualquiera, ni bandera de esplendor,
que no sienta mi derecho y d=E9 pecho a mi valor.=BB
