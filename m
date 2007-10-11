From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 0/7] TCP: small changes/fixes + lost_retrans brokeness fix
Date: Thu, 11 Oct 2007 14:41:00 +0300
Message-ID: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41696 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbXJKLlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some small and simple changes. Minor testing done, until I got
one LostRetrans counted, which turned out to be hard task than
I thought (without specifically arranged scenario, just some  
basic netem delay & drops).                              
                                                         
Lost_retrans handling fix is now tested, I fixed one incorrectly
placed if from the lost_retrans_low patch after reading it
through.                                                  
                                                         
...Recount removal patch could be more elegant in the way it
plays around with the tcp_clear_retrans, but I just wasn't able
to figure out how to do that nicely enough...            
                                                         
Those cleanups are preparation for DSACK fix, which is yet to      
be done but IMHO they won't hurt if applied alone either.      
                                 

Dave, please apply at will. FYI, I'll post also the SACK rewrite
patchset rebased after this (built on top of these).

--
 i.


