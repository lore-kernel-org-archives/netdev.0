From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: about phonet pipe controller
Date: Wed, 12 Oct 2011 14:08:52 +0300
Message-ID: <1435035.dDgLtNNFnF@leon.remlab.net>
References: <81C3A93C17462B4BBD7E272753C105791EAACAE76F@EXDCVYMBSTM005.EQ1STM.local> <3025840.a3oI7lSnik@leon.remlab.net> <81C3A93C17462B4BBD7E272753C105791EAACAEA43@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:19205 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab1JLLIx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 07:08:53 -0400
Received: from leon.remlab.net (helruo-dhcp021135.ntc.nokia.com [172.21.21.135])
	by mgw-sa02.nokia.com (Switch-3.4.4/Switch-3.4.3) with ESMTP id p9CB8nON001485
	for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 14:08:49 +0300
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791EAACAEA43@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mercredi 12 Octobre 2011 12:58:08 ext Hemant-vilas RAMDASI a =E9crit=
 :
> Yes, I agree that build-time option is not required..But what are tho=
se
> corner cases?

This is old stuff. I don't remember the details, nor did I investigate =
the=20
whole thing. But the code seemed to assume that userspace are fully tru=
sted,=20
the remote Phonet nodes also. That does not work.

Protocol-level race conditions, API level race conditions, crashed remo=
te=20
peers, crashing user space processes, invalid API use, etc. All that ne=
eds to=20
be dealt with safely. This is kernel code!

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
