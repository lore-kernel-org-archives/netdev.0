From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/5] 2.6.22-rc4: known regressions
Date: Tue, 05 Jun 2007 16:43:55 +0200
Message-ID: <466576AB.1090806@googlemail.com>
References: <46657407.1000108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Gary Zambrano <zambrano@broadcom.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>,
	Paulo Pereira <pfmp.404@gmail.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Samuel Ortiz <samuel@sortiz.org>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>,
	linux-pcmcia@lists.infradead.org,
	Robert de Rooy <robert.de.rooy@gmail.com>,
	Alan Cox <alan@redhat.com>, Tejun Heo <htejun@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:32217 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764815AbXFEOoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:44:11 -0400
Received: by ug-out-1314.google.com with SMTP id j3so192461ugf
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 07:44:11 -0700 (PDT)
In-Reply-To: <46657407.1000108@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc4.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Networking

Subject    : list_add corruption. prev->next should be next (f7d28794),=
 but was f0df8ed4 (prev=3Df0df8ed4) Kernel Bug at lib/list_debug.c:33
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8561
Submitter  : Paulo Pereira <pfmp.404@gmail.com>
Handled-By : Alan Stern <stern@rowland.harvard.edu>
Status     : problem is being debugged

Subject    : no irda0 interface (2.6.21 was OK), smsc does not find chi=
p
References : http://lkml.org/lkml/2007/6/3/16
Submitter  : Andrey Borzenkov <arvidjaar@mail.ru>
Handled-By : Samuel Ortiz <samuel@sortiz.org>
             Bjorn Helgaas <bjorn.helgaas@hp.com>
Status     : problem is being debugged

Subject    : b44: regression in 2.6.22
References : http://lkml.org/lkml/2007/5/27/108
Submitter  : Maximilian Engelhardt <maxi@daemonizer.de>
Handled-By : Gary Zambrano <zambrano@broadcom.com>
             Michael Buesch <mb@bu3sch.de>
             Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged



PCMCIA

Subject    : libata and legacy ide pcmcia failure
References : http://lkml.org/lkml/2007/5/17/305
Submitter  : Robert de Rooy <robert.de.rooy@gmail.com>
Status     : Unknown



Regards,
Michal

--
"Najbardziej brakowa=B3o mi twojego milczenia."
-- Andrzej Sapkowski "Co=B6 wi=EAcej"

