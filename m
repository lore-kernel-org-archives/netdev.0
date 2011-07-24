From: Rustam Afanasyev <cpulinker@yandex.ru>
Subject: Re: [Bugme-new] [Bug 39742] New: 2.6.39.3 crash and hangs in 1-2
 minutes with igb-RSS and L2TP PPTP services on the NAS server
Date: Sun, 24 Jul 2011 23:38:52 +0400
Message-ID: <4E2C74CC.3000407@yandex.ru>
References: <bug-39742-10286@https.bugzilla.kernel.org/> <20110722144214.577718f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward13.mail.yandex.net ([95.108.130.120]:35708 "EHLO
	forward13.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab1GXTuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 15:50:17 -0400
In-Reply-To: <20110722144214.577718f0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
I apply patch from this thread.
-----------------------------------------
--- Comment #2 from xeb@mail.ru  2011-07-23 15:42:04 ---
Please check this message http://www.spinics.net/lists/netdev/msg170766.html
maybe it is the reason.
-----------------------------------------
Now :
[root@nas3 ~]# uptime
  23:36:49 up 1 day, 41 min,  1 user,  load average: 0.00, 0.01, 0.05
[root@nas3 ~]#
Seems it work! There is now strange hangs and panic.
