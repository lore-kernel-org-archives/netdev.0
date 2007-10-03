From: Sonny <smaniaol@gmail.com>
Subject: kernel 2.4 vs 2.6 Traffic Controller performance
Date: Wed, 3 Oct 2007 14:14:50 +0800
Message-ID: <9dbec86d0710022314o6db2b0baua6db543d52f312b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:54749 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbXJCGOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 02:14:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so3873966wxd
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 23:14:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
This is a repost, there seems to have a misunderstanding before.

I hope this is the right place to ask this. Does any know if there is a
substantial difference in the performance of the traffic controller
between kernel 2.4 and 2.6. We tested it using 1 iperf server and use
250 and 500 clients, altering the burst.

This is the set-up:
iperf client -  router (w/ traffic controller) - iperf server

We use the top command inside the router to check the idle time of our
router to see this. The results we got from the 2.4 kernel shows
around 65-70% idle time while the 2.6 shows
60-65% idle time. We tried to use MRTG and we're not getting any
results either. We want to know if we could improve the bandwidth by
upgrading the kernel, else we would have to get a new bandwidth
manager.  Have anyone performed a similar test or can suggest a better
way to do this. Thanks in advance.
