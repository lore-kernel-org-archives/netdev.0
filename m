From: Lokesh <lokeshnb@intoto.com>
Subject: Async processing using NetFilters
Date: Mon, 23 Apr 2007 18:05:53 +0530
Message-ID: <200704231231.l3NCVlhD014873@brahma.intotoind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-66-80-10-146.dsl.sca.megapath.net ([66.80.10.146]:3948 "EHLO
	barracuda.intoto.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030994AbXDWMne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 08:43:34 -0400
Received: from brahma.intotoind.com (unknown [172.16.1.10])
	by barracuda.intoto.com (Spam Firewall) with ESMTP id 52694444F9
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 05:31:56 -0700 (PDT)
Received: from Lokesh.intoto.com (4mc78.hyd.intoto.com [172.16.4.78])
	by brahma.intotoind.com (8.12.11/8.12.8) with ESMTP id l3NCVlhD014873
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 18:01:48 +0530
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,
I posted this to Netfiler list but got no response.
dont know if it is a right place to ask this question, but any 
answer/clue will be helpful to me.
Thanks
-Lokesh


>I'm using Linux RedHat 9  kernel version 2.4.20-8
>I want to do some asynchronous processing of packets in my kernel 
>module that is registered as
>Netfilter Hook. I tried to make use of NF_QUEUE but found that only 
>one call back function per
>protocol family (PF) is provided and already some module (probably 
>NET_LINK socket interface)
>is making use of it for PF_INET.  Is there any way to use NF_QUEUE 
>facility without disturbing
>NET_LINK ? why per hook registration of call back function of 
>NF_QUEUE is not provided?
>How to proceed if someone had to do async processing of packets so 
>that pkts can be queued to crypto hardware processing unit and can 
>be safely reinjected back into kernel later so that other registered 
>hooks can get pkts?
>any help is highly appreciated.
>Thanks



********************************************************************************
This email message (including any attachments) is for the sole use of the intended recipient(s) 
and may contain confidential, proprietary and privileged information. Any unauthorized review, 
use, disclosure or distribution is prohibited. If you are not the intended recipient, 
please immediately notify the sender by reply email and destroy all copies of the original message. 
Thank you.
 
Intoto Inc. 

