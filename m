From: Peter Bieringer <pb@bieringer.de>
Subject: sysctl net.ipv6.conf.eth0.use_tempaddr only recogniced on interface
 start?
Date: Mon, 30 Aug 2004 10:09:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <F5812425CD96109163291692@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist USAGI-users <usagi-users@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>,
        Maillist initscripts-ipv6 <initscripts-ipv6@deepspace6.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

during playing around with RFC3041 capability in Linux kernel, I recognized
that the toggle (e.g. net.ipv6.conf.eth0.use_tempaddr) in sysctl is only
recognized if interface state changes from down to up, which means you
can't enable RFC3041 on an already running interface.

Is this 

a) by design
b) temporary issue, will be solved later
c) bug, will be solved soon

I would need an answer because I want to implement support for this feature
in initscripts-ipv6, and it has a major impact on the location where to put
the related scripting code.

In case of a) -> before interface goes up, "ifup" needs to be extended
In case of b),c) -> "ifup-ipv6" can be extended

Thank you very much for any hint,
        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
