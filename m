From: Rick Jones <rick.jones2@hp.com>
Subject: specifying scopid's for link-local IPv6 addrs
Date: Mon, 23 Jul 2007 12:01:19 -0700
Message-ID: <46A4FAFF.8010809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:37077 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759484AbXGWTBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 15:01:20 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel10.hp.com (Postfix) with ESMTP id E791434B96
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 12:01:19 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id MAA28002
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 12:01:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks -

People running netperf have reported that they have trouble with IPv6 under 
Linux.  Specifically, wereas the use of link-local IPv6 addresses "just works" 
in netperf under a number of "other OSes" they do not under Linux.  I'm 
ass-u-me-ing 2.6 here, but not sure exactly which ones - I've seen it on a 
2.6.18-based RHEL5.

Some poking about and conversation has suggested that one has to set a 
sin6_scope_id in the sockaddr_in6.  This needs to be an index of one of the 
interfaces in the system, which I presume means walking some additional structures.

Is this a requirement which might be expected to remain in the future, or is it 
something which might just go away?  That will have an effect on netperf future 
development.

thanks,

rick jones
