From: Shirley Ma <xma@us.ibm.com>
Subject: New IPv6 Draft Implementation
Date: Thu, 11 Sep 2003 14:42:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF214DECF9.D994A353-ON87256D9E.00760932@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





I am going to implement the support for the new IP MIBs draft for IPv6 MIBs
only.

Below is the draft link:

http://www.ietf.org/internet-drafts/draft-ietf-ipv6-rfc2011-update-03.txt.

This draft is in the shape of last call. This draft consists of 11 tables,
ipv6InterfaceTable, ipSystemStatsTable, ipIfStatsTable,
ipAddressPrefixTable, ipAddresTable, InetNetToMediaTable,
ipv6ScopeZoneIndexTable, ipDefaultRouterTable, ipv6RouterAdverTable,
inetIcmpTable and inetIcmpMsgTable. There are hundreds of objects in these
tables. Some of the objects can be archived through netlink from 2.6.0
kernel already. Some of them are not. All the new objects are going to be
archived through netlink socket. I am going to start from
ipv6nterfaceTable. Any thoughts about this?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
