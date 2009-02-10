From: Joe Pruett <joey@clean.q7.com>
Subject: ipsec and netfilter
Date: Tue, 10 Feb 2009 11:42:47 -0800 (PST)
Message-ID: <alpine.LRH.2.00.0902101138380.21337@q7.q7.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from q7.q7.com ([207.173.201.42]:36252 "EHLO q7.q7.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754966AbZBJUfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 15:35:46 -0500
Received: from q7.q7.com (localhost [127.0.0.1])
	by q7.q7.com (8.13.1/8.13.1) with ESMTP id n1AJgmxO012363
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 11:42:48 -0800
Received: from localhost (joey@localhost)
	by q7.q7.com (8.13.1/8.13.1/Submit) with ESMTP id n1AJglMH012358
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 11:42:47 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i've asked this on the netfilter list with no responses and there doesn't 
seem to be an ipsec list for linux anymore, so maybe someone here will 
have some insight...

why aren't esp/ah packets run through netfilter again after 
decryption/decapsulation?  in tunnel mode, packets do get sent in again, 
but that is only because ip-ip does that, not the ipsec code.

i want to set up a host2host ipsec connection and be able to do standard 
filtering on it, but the hooks just don't seem to be there.  or am i 
missing something?
