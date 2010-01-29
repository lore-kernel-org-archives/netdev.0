From: Pekka Savola <pekkas@netcore.fi>
Subject: IPV6_DONTFRAG sockopt etc.
Date: Fri, 29 Jan 2010 11:44:27 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1001291138310.29525@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:57368 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932312Ab0A2KAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 05:00:53 -0500
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id o0T9iRE9029680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 11:44:27 +0200
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id o0T9iREM029677
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 11:44:27 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There appear to be a couple of sockopts in RFC3542 that aren't 
implemented yet (they're #if 0'd in the code)

#define IPV6_RECVPATHMTU        60
#define IPV6_PATHMTU            61
#define IPV6_DONTFRAG           62
#define IPV6_USE_MIN_MTU        63

In one particular app, I would have found IPV6_DONTFRAG useful.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
