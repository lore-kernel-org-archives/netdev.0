From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42912] Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue
Date: Mon, 12 Mar 2012 09:27:58 -0700
Message-ID: <20120312092758.7eec914d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50854 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab2CLQ2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 12:28:00 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 0AC64141000D
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:28:00 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SCvgdIQeqysY for <netdev@vger.kernel.org>;
	Mon, 12 Mar 2012 09:27:59 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 2064F1410001
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 09:27:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 12 Mar 2012 16:24:43 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42912] Kernel freeze. tcp_input.c:3418 tcp_clean_rtx_queue


https://bugzilla.kernel.org/show_bug.cgi?id=42912





--- Comment #2 from Reinis Rozitis <r@roze.lv>  2012-03-12 16:24:43 ---
I have found that a similar bug has been reported with some earlier kernel
version ( https://bugzilla.kernel.org/show_bug.cgi?id=31282 ), but the status
has never been changed.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
