From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 00:52:52 +0100
Message-ID: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfrost@snowman.net
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We had the same problem. Seems to be a limitation of the pfkey-implementation 
of linux.

racoon and setkey both use the pfkey-interface.

We switched to iproute2 and openswan which both use the netfilter-interface. 
Therefor they can handle thousands of SAD and SPD rules.

Greetings,

Wolfgang Walter
