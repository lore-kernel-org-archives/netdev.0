From: denys@visp.net.lb
Subject: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 14:14:26 +0200
Message-ID: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60487 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab1AZMOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 07:14:36 -0500
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPA id DB34D2EC03F
	for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 14:14:26 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I am running server (TCP accelerator), which is initiating more than 
 40K connections.
 Each instance of server bound to separate IP, and each of them handling 
 around 5-10K connections.
 At moments, when i have excessive connect/disconnect events if i try to 
 establish connection even from IP is not used,
 during bind() i am getting errno "Address already in use".
 What can be the issue?
 Will it help if i increase in kernel hardcoded limit from 64K TCP bind 
 hash entries to higher values?
