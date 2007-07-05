From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: Big sized packets have been dropped strangly
Date: Thu, 05 Jul 2007 18:01:30 -0400
Message-ID: <468D6A3A.3040101@tmr.com>
References: <468B642D.9030109@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gshan <gshan@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:34742 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbXGILSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 07:18:45 -0400
In-Reply-To: <468B642D.9030109@alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gshan wrote:
> Hey Guys,
> 
> I got a strange problem recently but no ideas, so to post the question 
> here. We have a FPGA what finish ATM AAL5 to ethernet frame, and CPU 
> receives IP packets from it. The interface based on the FPGA (called 
> sar0) has been bound with several IP addresses. When the MTU of the 
> interface is configurated to 1500, trivial packets can be received, but 
> big-sized packets are dropped. If the MTU is increased to 9500, 
> everything is ok except the NFS connection. We mounted with another 
> machine through sar0. When the MTU is 9500, the speed of the NFS becomes 
> very very slow (it almost took 10 minutes to transfer 100KB files).
> 
> I don't know why it is and how to solve it. Any suggestions are 
> appreciated!
> 
http://groups.google.com/group/fa.linux.kernel/msg/4434f7c5d38d9292

I think that's relevant.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
