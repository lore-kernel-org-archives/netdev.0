From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.22-rc4: known regressions with patches v2
Date: Sat, 09 Jun 2007 19:40:36 +0200
Message-ID: <466AE614.3080706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	=?ISO-8859-2?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>,
	Dave Airlie <airlied@linux.ie>,
	Christoph Lameter <clameter@sgi.com>,
	Andrea Righi <righiandr@users.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>,
	Samuel Ortiz <samuel@sortiz.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>,
	Strobl Anton <a.strobl@aws-it.at>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:5846 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757819AbXFIRky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 13:40:54 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1177072ugf
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 10:40:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc4
with patches available.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Unclassified

Subject    : kernel BUG at arch/i386/kernel/cpu/perfctr-watchdog.c:126!
References : http://lkml.org/lkml/2007/6/3/60
Submitter  : Udo A. Steinberg <us15@os.inf.tu-dresden.de>
Handled-By : Bj=F6rn Steinbrink <B.Steinbrink@gmx.de>
Patch      : http://lkml.org/lkml/2007/6/8/23
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

Subject    : no irda0 interface (2.6.21 was OK), smsc does not find chi=
p
References : http://lkml.org/lkml/2007/6/3/16
Submitter  : Andrey Borzenkov <arvidjaar@mail.ru>
Handled-By : Samuel Ortiz <samuel@sortiz.org>
             Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch      : http://lkml.org/lkml/2007/6/7/237
Status     : patch was suggested



Regards,
Michal

--
"Najbardziej brakowa=B3o mi twojego milczenia."
-- Andrzej Sapkowski "Co=B6 wi=EAcej"
