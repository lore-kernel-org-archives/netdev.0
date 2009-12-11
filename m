From: David Daney <ddaney@caviumnetworks.com>
Subject: Custom hardware Qdisc...
Date: Fri, 11 Dec 2009 10:26:08 -0800
Message-ID: <4B228EC0.80105@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:18450 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbZLKS1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 13:27:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our hardware (Octeon SOC) has fairly flexible packet output queuing that 
can be done completely in hardware.

I am thinking of trying to take advantage of this in the driver 
(currently in drivers/staging/octeon).

At a very hige level my tentative plan is to implement a custom  Qdisc 
that has an enqueue method that places the packets directly in the 
output queues after they are classified.

The dequeue method would be a noop returning NULL because once the 
packets are on the queues, no further action is needed from the driver.

Does doing something like this seem plausible?  If not, what are the 
main problems I might be overlooking?

Thanks in advance,
David Daney
