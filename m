From: Olaf Hering <olh@suse.de>
Subject: limited number if iptable rules on 64bit hosts
Date: Wed, 2 Feb 2005 14:38:51 +0100
Message-ID: <20050202133851.GA9680@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What buffer or sysctrl value has to change to allow more than 3445 rules
like this (on a 64bit host with 64bit iptables)?

iptables -A FORWARD -j ACCEPT

setsockopt(3, SOL_IP, 0x40 /* IP_??? */,
"filter\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 524368) =
-1 ENOMEM (Cannot allocate memory)

I see this with 2.6.5 and 2.6.11.
