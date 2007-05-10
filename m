From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.21-gitX: known regressions
Date: Thu, 10 May 2007 14:04:13 +0200
Message-ID: <46430A3D.4030004@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	David Chinner <dgc@sgi.com>, pavel@suse.cz,
	linux-pm@lists.linux-foundation.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Alexey Dobriyan <adobriyan@sw.ru>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Doug Chapman <doug.chapman@hp.com>,
	Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:62075 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbXEJMEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:04:22 -0400
Received: by ik-out-1112.google.com with SMTP id b35so357388ika
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 05:04:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.21-gitX.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Unclassified:

Subject    : 2.6.21-git10/11: files getting truncated on xfs (after suspend/resume?)
References : http://lkml.org/lkml/2007/5/9/410
Submitter  : Jeremy Fitzhardinge <jeremy@goop.org>
Handled-By : David Chinner <dgc@sgi.com>
Status     : problem is being debugged

Subject    : Current -git kernel kills X
References : http://lkml.org/lkml/2007/5/8/667
Submitter  : Jeff Garzik <jeff@garzik.org>
Status     : Unknown



Block devices:

Subject    : BUG in loop.ko
References : http://lkml.org/lkml/2007/5/9/510
Submitter  : Jeremy Fitzhardinge <jeremy@goop.org>
Status     : Unknown



Networking:

Subject    : panic with e1000 driver on HP Integrity servers
References : http://bugzilla.kernel.org/show_bug.cgi?id=8455
Submitter  : Doug Chapman <doug.chapman@hp.com>
Caused-By  : Auke Kok <auke-jan.h.kok@intel.com>
             commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
Status     : Unknown



Timers/NOHZ:

Subject    : 2.6.21-git4 BUG: soft lockup detected on CPU#1! 
References : http://lkml.org/lkml/2007/5/2/511
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged



Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
