From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Wed, 16 Nov 2011 12:15:17 +0200
Message-ID: <1338128.PsNU0JUHaL@hector>
References: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com> <3443203.gVgdO3ogFg@hector> <81C3A93C17462B4BBD7E272753C105791FB0A0F045@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:62549 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394Ab1KPKPD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 05:15:03 -0500
Received: from hector.localnet (esdhcp034220.research.nokia.com [172.21.34.220])
	by mgw-sa01.nokia.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id pAGAF2rN015802
	for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 12:15:02 +0200
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB0A0F045@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mercredi 16 Novembre 2011 09:46:07 ext Hemant-vilas RAMDASI a =E9cri=
t :
> > Why and how?
>=20
> This is needed for user to poll pipe-state.

The pipe state is already exposed with poll() for all that user space s=
hould=20
ever need to care about.

Polling state with getsockopt would probably break power management any=
way.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
