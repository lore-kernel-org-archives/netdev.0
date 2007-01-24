From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.20-rc5: known regressions with patches (v3)
Date: Wed, 24 Jan 2007 16:50:53 +0100
Message-ID: <20070124155053.GL17836@stusta.de>
References: <Pine.LNX.4.64.0701121424520.11200@woody.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	=?utf-8?B?QmrDtnJu?= Steinbrink <B.Steinbrink@gmx.de>,
	Robert Hancock <hancockr@shaw.ca>, jgarzik@pobox.com,
	linux-ide@vger.kernel.org,
	Michael Gernoth <gernoth@informatik.uni-erlangen.de>,
	Daniel Drake <dsd@gentoo.org>,
	David L Stevens <dlstevens@us.ibm.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Dave Jones <davej@redhat.com>,
	cpufreq@lists.linux.org.uk, lenb@kernel.org,
	linux-acpi@vger.kernel.org
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:2081 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751437AbXAXPuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 10:50:46 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701121424520.11200@woody.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.20-rc5 compared to 2.6.1=
9
with patches available.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possib=
ly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering=
=2E


Subject    : sata_nv: SATA exceptions
References : http://lkml.org/lkml/2007/1/14/108
Submitter  : Bj=C3=B6rn Steinbrink <B.Steinbrink@gmx.de>
Caused-By  : Robert Hancock <hancockr@shaw.ca>
             commit 2dec7555e6bf2772749113ea0ad454fcdb8cf861
Handled-By : Robert Hancock <hancockr@shaw.ca>
Patch      : http://lkml.org/lkml/2007/1/23/280
Status     : patch available


Subject    : does not pickup ipv6 addresses
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7817
             http://lkml.org/lkml/2007/1/14/146
Submitter  : Michael Gernoth <gernoth@informatik.uni-erlangen.de>
             Daniel Drake <dsd@gentoo.org>
Caused-By  : David L Stevens <dlstevens@us.ibm.com>
             commit 30c4cf577fb5b68c16e5750d6bdbd7072e42b279
Handled-By : YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=3D7817
Status     : patch available


Subject    : ACPI: fix cpufreq regression
References : http://lkml.org/lkml/2007/1/16/120
Submitter  : Ingo Molnar <mingo@elte.hu>
Caused-By  : Dave Jones <davej@redhat.com>
             commit 0916bd3ebb7cefdd0f432e8491abe24f4b5a101e
Handled-By : Ingo Molnar <mingo@elte.hu>
Patch      : http://lkml.org/lkml/2007/1/16/120
Status     : patch available


