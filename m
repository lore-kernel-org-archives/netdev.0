From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Sun, 6 May 2012 01:01:55 +0200
Message-ID: <20120505230155.GA3300@electric-eye.fr.zoreil.com>
References: <20120503064726.GA17337@electric-eye.fr.zoreil.com> <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec> <4FA3EE49.7070805@palosanto.com> <4FA59F5B.5000800@palosanto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw61z?= Lasso <a_villacis@palosanto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52268 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752006Ab2EEXIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 19:08:04 -0400
Content-Disposition: inline
In-Reply-To: <4FA59F5B.5000800@palosanto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
[...]
> It happened again, on a non-tainted kernel. The dmesg log is attached=
=2E

It sucks.

Can you do a poor man's bisection of the r8169 driver between v3.3 and
v3.4-rc1  (aka 'git cat-file -p $some_rev:drivers/net/ethernet/realtek/=
r8169.c')

I'd try 1e874e041fc7c222cbd85b20c4406070be1f687a then
8027aa245bbd125350f6a78c5a78771d143aba55 if it does not fail.

--=20
Ueimor
