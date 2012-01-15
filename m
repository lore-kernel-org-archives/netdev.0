From: "Anatoly Sivov" <mm05@mail.ru>
Subject: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 19:11:31 +0400
Message-ID: <op.v74shh18fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.mail.ru ([94.100.176.132]:33517 "EHLO smtp5.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653Ab2AOPKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 10:10:35 -0500
Received: from [95.175.225.55] (port=24799 helo=stalin)
	by smtp5.mail.ru with esmtpa (envelope-from <mm05@mail.ru>)
	id 1RmRj7-0003wF-FO
	for netdev@vger.kernel.org; Sun, 15 Jan 2012 19:10:34 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone.

struct sk_buff has a field tstamp, which is used for high resolution rtt  
calculation.
All operations with this field are done directly or indirectly via ktime_*  
interface,
which uses getnstimeofday function.
My question is why does skb->tstamp use getnstimeofday?
Isn't it better to use getrawmonotonic, where we are not inetrfered with  
ntp,  for rtt calculation?

Thank you.
