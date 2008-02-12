From: Rick Jones <rick.jones2@hp.com>
Subject: permisions for Ethetool vs rtnetlink
Date: Tue, 12 Feb 2008 14:08:54 -0800
Message-ID: <47B218F6.3070903@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:9026 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875AbYBLWI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 17:08:56 -0500
Received: from g1t0027.austin.hp.com (localhost.localdomain [127.0.0.1])
	by receive-from-antispam-filter (Postfix) with SMTP id 09A0138143
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 22:08:56 +0000 (UTC)
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id CB6F738050
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 22:08:55 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id OAA13498
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 14:08:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been further enhancing the netperf omni tests to enable reporting 
stuff like uname for local/remote, the name of the probable egress 
interface (rtnetlink), and then driver information for that interface. 
I figure that such information being spat-out by netperf might be useful 
to have if one were setting-up a database of results and/or making 
regression checks and the like.

It struck me as a little odd that I can retrieve routing information for 
a destination as a mere mortal, but to retreive driver information for 
an interface I have to be priviledged.  At first glance I would think 
the sensitivity of both sets of information would be about the same?

Is the difference simply an artifact of history?

sincerely,

rick jones
