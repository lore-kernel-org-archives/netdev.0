From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.22-rc4: known regressions with patches
Date: Tue, 05 Jun 2007 16:54:28 +0200
Message-ID: <46657924.4010505@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk,
	Uwe Bugla <uwe.bugla@gmx.de>, Ken Chen <kenchen@google.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Christoph Lameter <clameter@sgi.com>,
	Dave Airlie <airlied@linux.ie>,
	Andrea Righi <righiandr@users.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>,
	Strobl Anton <a.strobl@aws-it.at>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:51317 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbXFEOyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:54:45 -0400
Received: by mu-out-0910.google.com with SMTP id i10so2243964mue
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 07:54:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc4
with patches available.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Block devices

Subject    : loop devices limited to one single device
References : http://lkml.org/lkml/2007/5/16/229
Submitter  : Uwe Bugla <uwe.bugla@gmx.de>
Handled-By : Ken Chen <kenchen@google.com>
Patch      : http://lkml.org/lkml/2007/5/21/483
Status     : patch available



=46ile systems

Subject    : JFFS2 issues
References : http://lists.infradead.org/pipermail/linux-mtd/2007-May/01=
8426.html
Submitter  : Haavard Skinnemoen <hskinnemoen@atmel.com>
Caused-By  : commit 10731f83009e2556f98ffa5c7c2cbffe66dacfb3
             Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Handled-By : Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Patch      : http://lists.infradead.org/pipermail/linux-mtd/2007-May/01=
8453.html
Status     : patch available



Memory management

Subject    : bug in i386 MTRR initialization
References : http://lkml.org/lkml/2007/5/19/93
Submitter  : Andrea Righi <righiandr@users.sourceforge.net>
Status     : patch available



Networking

Subject    : OOPS iproute2/tc/u32_destroy in 2.6.22-rc3-git6
References : http://lkml.org/lkml/2007/6/3/66
Submitter  : Strobl Anton <a.strobl@aws-it.at>
Handled-By : Patrick McHardy <kaber@trash.net>
Patch      : http://lkml.org/lkml/2007/6/3/137
Status     : patch available



Regards,
Michal

--
"Najbardziej brakowa=B3o mi twojego milczenia."
-- Andrzej Sapkowski "Co=B6 wi=EAcej"
