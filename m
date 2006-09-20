From: Pekka Savola <pekkas@netcore.fi>
Subject: Suspend/Resume: IPv6 default route gets lost
Date: Wed, 20 Sep 2006 10:49:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0609201043290.31679@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:12266 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1751287AbWITHtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 03:49:52 -0400
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.12.11.20060614/8.12.11) with ESMTP id k8K7noch001772
	for <netdev@vger.kernel.org>; Wed, 20 Sep 2006 10:49:50 +0300
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm using FC5 w/ 2.6.17-1.2174_FC5.  When the laptop resumes from 
suspend, it does not re-send an IPv6 route solicitation.  So, if the 
IPv6 default route expired while you were in suspend, you'll have to 
wait for the next multicast unsolicited RA.

A workaround is to cycle the interface at ACPI resume scripts.

Maybe triggering a RS is a missing feature in suspend/resume kernel 
functionality?

There has also been discussion (years ago) about user-space interface 
to triggering a RS, but AFAIK, none exists right now.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
