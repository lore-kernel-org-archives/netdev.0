From: Ben Greear <greearb@candelatech.com>
Subject: TSO and 2.6.13.2
Date: Tue, 08 Nov 2005 16:44:05 -0800
Message-ID: <43714655.2050001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It appears that I can (almost?) completedly deadlock a
TCP connection when using TSO on 2.6.13.2.  My test involves
trying to send 200Mbps between two interfaces.  With TSO enabled (ie, the default
for e1000 NICs), in less than 1 minute, there are no more packets transmitted,
though it does run nice and fast untill it completely breaks :P

I disabled TSO with ethtool, and now it seems to be working reliably.

I can attempt to grab network traces if this is worth pursuing.

Considering the ongoing troubles with TSO, it is my opinion that it
should be disabled by default...but maybe I'm just unlucky.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
