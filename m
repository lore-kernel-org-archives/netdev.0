From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Bug #12868] iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Date: Sat, 21 Mar 2009 21:16:48 +0100
Message-ID: <87iqm2hbrj.fsf__13109.4428048984$1237666876$gmane$org@nemi.mork.no>
References: <HPkmj74uawF.A.iqE.M8TxJB@chimera>
	<fnEpM0mQZjO.A.o3E.S8TxJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List
	<public-linux-kernel-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>,
	Kernel Testers List
	<public-kernel-testers-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>,
	"Jan Engelhardt"
	<public-jengelh-nopoi9nDyk+ELgA04lAiVw@hugh.gmane.org>,
	"netdev" <public-netdev-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>,
	"Stephen Hemminger"
	<public-shemminger-ZtmgI6mnKB3QT0dZR+AlfA@hugh.gmane.org>
To: "Rafael J. Wysocki" <public-rjw-KKrjLPT3xs0@hugh.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:48699 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbZCUUTT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:19:19 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public@hugh.gmane.org>)
	id 1Ll7f0-0001hi-BU
	for netdev@vger.kernel.org; Sat, 21 Mar 2009 21:19:14 +0100
In-Reply-To: <fnEpM0mQZjO.A.o3E.S8TxJB@chimera> (Rafael J. Wysocki's message
	of "Sat, 21 Mar 2009 18:07:29 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org> writes:

> This message has been generated automatically as a part of a report
> of regressions introduced between 2.6.27 and 2.6.28.
>
> The following bug entry is on the current list of known regressions
> introduced between 2.6.27 and 2.6.28.  Please verify if it still shou=
ld
> be listed and let me know (either way).
>
>
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12868
> Subject		: iproute2 and regressing "ipv6: convert tunnels to net_devi=
ce_ops"
> Submitter	: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gma=
ne.org>
> Date		: 2009-03-09 14:46 (13 days old)
> First-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1326c3d5a4b792a2b15877feb7fb691f8945d203
> References	: http://marc.info/?l=3Dlinux-netdev&m=3D123660999632730&w=
=3D4


This is fixed by commit 1b1d8f73a44fe1796a73a97ebcb08cad18b97f07
currently in davem's net-2.6 tree.


Bj=C3=B8rn


