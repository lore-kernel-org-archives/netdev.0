From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.21-rc1: known regressions (part 3)
Date: Sun, 25 Feb 2007 19:02:51 +0100
Message-ID: <20070225180251.GD12392@stusta.de>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, Kay Sievers <kay.sievers@vrfy.org>,
	Greg KH <greg@kroah.com>, Michael-Luke Jones <mlj28@cam.ac.uk>,
	Pete Clements <clem@clem.clem-digital.net>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Chuck Lever <chuck.lever@oracle.com>,
	Andreas Schwab <schwab@suse.de>, Dave Jones <davej@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:43926 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932649AbXBYSCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 13:02:51 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.21-rc1 compared to 2.6.2=
0
that are not yet fixed in Linus' tree.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possib=
ly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering=
=2E


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Status     : unknown


Subject    : natsemi ethernet card not detected correctly
References : http://lkml.org/lkml/2007/2/23/4
             http://lkml.org/lkml/2007/2/23/7
Submitter  : Bob Tracy <rct@gherkin.frus.com>
Caused-By  : Mark Brown <broonie@sirena.org.uk>
Handled-By : Mark Brown <broonie@sirena.org.uk>
Patch      : http://lkml.org/lkml/2007/2/23/142
Status     : patch available


Subject    : request_module: runaway loop modprobe net-pf-1
References : http://lkml.org/lkml/2007/2/21/206
Submitter  : YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <=
yoshfuji@linux-ipv6.org>
Caused-By  : Kay Sievers <kay.sievers@vrfy.org>
             commit c353c3fb0700a3c17ea2b0237710a184232ccd7f
Handled-By : Greg KH <greg@kroah.com>
Status     : problem is being discussed


Subject    : IPV6=3Dm, SUNRPC=3Dy compile error
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8050
             http://lkml.org/lkml/2007/2/12/442
             http://lkml.org/lkml/2007/2/20/384
Submitter  : Michael-Luke Jones <mlj28@cam.ac.uk>
             Pete Clements <clem@clem.clem-digital.net>
             Sid Boyce <g3vbv@blueyonder.co.uk>
Caused-By  : Chuck Lever <chuck.lever@oracle.com>
Handled-By : YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <=
yoshfuji@linux-ipv6.org>
Status     : patch available


Subject    : WARNING: "compat_agp_ioctl" undefined!
References : http://lkml.org/lkml/2007/2/21/272
Submitter  : Andreas Schwab <schwab@suse.de>
Handled-By : Dave Jones <davej@redhat.com>
Status     : patch available


