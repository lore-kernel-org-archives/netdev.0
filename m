From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Generic netlink interface help
Date: Thu, 24 May 2007 10:59:59 +0200
Message-ID: <20070524085956.GP7089@enneenne.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:35792 "EHLO
	mail.enneenne.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112AbXEXJ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 05:28:48 -0400
Received: from zaigor.enneenne.com ([192.168.32.1])
	by mail.enneenne.com with esmtp (Exim 4.50)
	id 1Hr982-0004Jb-Bu
	for netdev@vger.kernel.org; Thu, 24 May 2007 10:57:05 +0200
Received: from giometti by zaigor.enneenne.com with local (Exim 4.63)
	(envelope-from <giometti@enneenne.com>)
	id 1Hr9At-0005QK-4E
	for netdev@vger.kernel.org; Thu, 24 May 2007 10:59:59 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm trying to use this new API for my LinuxPPS support but I have some
difficulties in understanding the code!

Looking at http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO
is not clear... for example in line:

   msg_head = genlmsg_put(skb, pid, seq, type, 0, flags, DOC_EXMPL_C_ECHO, 1);

what "pid", "seq", "type" and "flags" stand for?

It could be possible to have a little kernel module implementing the
ECHO function as example to compile and test?

Again, I read in a message from Jamal Hadi Salim regarding Kernel <
--> User space Communication that:

 Essentially nothing new, Communication is as in standard netlink
 approach.  i.e from user space you open a netlink socket to the
 kernel - in this case family NETLINK_GENERIC - and send and receive
 response as well as asynchronous events.  To receive to events you
 subscribe to specific multicast groups.

So I suppose I can modify a little my userland programs using old API
in order to support this new API. Is that right?

Thanks,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127
