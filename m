From: gshan <gshan@alcatel-lucent.com>
Subject: Big sized packets have been dropped strangly
Date: Wed, 04 Jul 2007 17:11:09 +0800
Message-ID: <468B642D.9030109@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759632AbXGDJL2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Guys,

I got a strange problem recently but no ideas, so to post the question 
here. We have a FPGA what finish ATM AAL5 to ethernet frame, and CPU 
receives IP packets from it. The interface based on the FPGA (called 
sar0) has been bound with several IP addresses. When the MTU of the 
interface is configurated to 1500, trivial packets can be received, but 
big-sized packets are dropped. If the MTU is increased to 9500, 
everything is ok except the NFS connection. We mounted with another 
machine through sar0. When the MTU is 9500, the speed of the NFS becomes 
very very slow (it almost took 10 minutes to transfer 100KB files).

I don't know why it is and how to solve it. Any suggestions are appreciated!

Thanks,
Gavin
