From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [2/2] 2.6.22-rc1: known regressions
Date: Sun, 13 May 2007 20:15:05 +0200
Message-ID: <464755A9.6@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Doug Chapman <doug.chapman@hp.com>,
	Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Thomas Gleixner <tglx@linutronix.de>,
	alsa-devel@alsa-project.org, "Takashi Iwai" <tiwai@suse.de>,
	"Jaroslav Kysela" <perex@suse.cz>,
	Pete Clements <clem@clem.clem-digital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:48895 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921AbXEMSPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 14:15:37 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1366036wxd
        for <netdev@vger.kernel.org>; Sun, 13 May 2007 11:15:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

(http://bugzilla.kernel.org/ is not available, information are not up-to-date)

Networking

Subject    : panic with e1000 driver on HP Integrity servers
References : http://bugzilla.kernel.org/show_bug.cgi?id=8455
Submitter  : Doug Chapman <doug.chapman@hp.com>
Caused-By  : Auke Kok <auke-jan.h.kok@intel.com>
             commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
Status     : problem is being debugged



Timers/NOHZ

Subject    : 2.6.21-git4 BUG: soft lockup detected on CPU#1! 
References : http://lkml.org/lkml/2007/5/2/511
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged



ALSA

Subject    : lost snd_4236 device
References : http://lkml.org/lkml/2007/5/13/87
Submitter  : Pete Clements <clem@clem.clem-digital.net>
Status     : Unknown



Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
