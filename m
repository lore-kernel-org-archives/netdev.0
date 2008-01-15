From: Mark Seger <Mark.Seger@hp.com>
Subject: Is there an easy way for non-privileged users to determine an interface's
 speed?
Date: Tue, 15 Jan 2008 16:07:21 -0500
Message-ID: <478D2089.9050701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:57464 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbYAOVHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 16:07:36 -0500
Received: from seeaxp.zko.hp.com (seeaxp.zko.hp.com [16.116.23.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by palrel12.hp.com (Postfix) with ESMTP id CED5B348C1
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 13:07:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the current answer is they can't but I also wanted to confirm it 
with this list.  I had hoped I might be able to find it in /proc, /sys 
or with a utility like ethtool or even ifconfig, but alas it's nowhere 
to be seen.  So if I'm correct, that leads to the second question of why 
not?  Would it be that tough to put it in under /sys/class/net/*?  One 
of the reasons I ask is that I'd like to be able to tell if a network 
pipe is nearing its capacity and so be able to alert someone about it 
when it occurs.
-mark


