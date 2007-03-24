From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 0/2] [iputils] MTU discovery changes
Date: Fri, 23 Mar 2007 20:46:25 -0400
Message-ID: <460474E1.9070805@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54572 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992642AbXCXAqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:46:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These add some changes that make tracepath a little more useful for 
diagnosing MTU issues.  The length flag helps distinguish between MTU 
black holes and other types of black holes by allowing you to vary the 
probe packet lengths.  Using PMTUDISC_PROBE gives you the same results 
on each run without having to flush the route cache, so you can see 
where MTU changes in the path actually occur.

The PMTUDISC_PROBE patch goes in should be conditional on whether the 
corresponding kernel patch (just sent) goes in.

   -John
