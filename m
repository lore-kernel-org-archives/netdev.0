From: Shirley Ma <xma@us.ibm.com>
Subject: [Issues] Implementation for IPv6 MIB:ipv6PrefixTable
Date: Wed, 22 Oct 2003 13:01:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBADF6ADC.FB447CDE-ON87256DC7.006394FF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi, Dave,

I have several implementation issues about ipv6PrefixTable for IPv6 MIBs.
This table must include all prefixes' info, manually configured prefix,
addrconf prefix, dhcp prefix ... In each ipv6PrefixTable, there are 9
objects, which are Ifindex, Type, Prefix, Length, Origin(addrconf,
manually, dhcp, others), OnLinkFlag, AutonomoueFlag, AdvPreferredLiftTime
and ValidLifeTime.
There is no such a table or similar list saved in Linux kernel. Manually
configured prefix router, and on-link addrconf prefix router are saved in
routing table, but only Prefix and Lengh objects there. The off-link or
on-link flag (set to 0) prefix router are not in routing table or anywhere
else, which are using default router by RFC 2461.
I would like to hear your opinion on the implementation. I read some email
thread before about a implementation of prefix list in the kernel. At that
time, the conclusion was not implementing prefix list in the kernel, and
also the prefix list only refers to onlink prefix by RFC2461.

First, do you think it's a good idea to save all prefix objects in routing
table?
Second, where is the best location for the off-link prefix, on-link flag 0
prefix to be saved?
Third, do you think it's a good idea to implement a prefix table/per
interface in the kernel?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
