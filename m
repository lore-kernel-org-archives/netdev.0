From: Moni Shoua <monis@voltaire.com>
Subject: problems with ib-bonding of 2.6.24-rc1
Date: Sun, 04 Nov 2007 18:15:30 +0200
Message-ID: <472DF022.3000604@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:55375 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752737AbXKDQPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 11:15:36 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I've been doing some tests for bonding of 2.6.24-rc1 and noticed some problems.
My first goal was to see how bonding works with IPoIB slaves but I also tried it
with Ethernet.

Basically, what I see is that after a while commands like ifconfig or ip stucks.
I only use sysfs  to configure bonding (which also stucks after a while).

After stripping the list of commits below from the code I see no problems.

Does anybody else have the same problem?

thanks
 MoniS



commit d0e81b7e2246a41d068ecaf15aac9de570816d63
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:51 2007 -0700

    bonding: Acquire correct locks in alb for promisc change
    
--
commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:50 2007 -0700

    bonding: Convert more locks to _bh, acquire rtnl, for new locking
    
--
commit 059fe7a578fba5bbb0fdc0365bfcf6218fa25eb0
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:49 2007 -0700

    bonding: Convert locks to _bh, rework alb locking for new locking
    
--
commit 0b0eef66419e9abe6fd62bc958ab7cd0a18f858e
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:48 2007 -0700

    bonding: Convert miimon to new locking
    
--
commit cf5f9044934658dd3ffc628a60cd37c70f8168b1
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:47 2007 -0700

    bonding: Convert balance-rr transmit to new locking
    
--
commit 1b76b31693d4a6088dec104ff6a6ead54081a3c2
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:45 2007 -0700

    Convert bonding timers to workqueues
    
--
commit 3a4fa0a25da81600ea0bcd75692ae8ca6050d165
Author: Robert P. J. Day <rpjday@mindspring.com>
Date:   Fri Oct 19 23:10:43 2007 +0200

    Fix misspellings of "system", "controller", "interrupt" and "necessary".
    
--
commit 1c3f0b8e07de78a86f2dce911f5e245845ce40a8
Author: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date:   Thu Oct 18 23:41:04 2007 -0700

    Change struct marker users
    

