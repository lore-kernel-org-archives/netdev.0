From: Shirley Ma <xma@us.ibm.com>
Subject: Re: New IPv6 Draft Implementation
Date: Fri, 12 Sep 2003 11:09:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF27F824BE.52261AA2-ON87256D9F.00625E61@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcin Kaminski <maxiu@man.poznan.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Great!. I am doing the kernel piece right now for supporting IPv6 MIBs.

There are total of 11 tables in IPv6 MIBs. I will work on the kernel patch
for supporting ipv6InterfaceTable, ipAddressTable(IPv6) and
ipAddressPrefixTable(IPv6 only) first, then inetIcmpTable(ICMPv6),
inetIcmpMsgTable (ICMPv6) ipv6RouterAdverTable and ipIfStatsTable(IPv6
only). There are no much kernel work on ipSystemStatsTable,
InetNetToMediaTable and ipDefaultRouterTable, which are already supported
in current kernel.  I won't do any work on ipv6ScopeZoneIndexTable, this
table has dependency on IPv6 Scoped Address Architecture draft.

Hope more people are interested in IPv6 MIBs work, and join the SNMP user
level development.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



Marcin Kaminski <maxiu@man.poznan.pl> on 09/11/2003 02:58:30 PM

To:    Shirley Ma/Beaverton/IBM@IBMUS
cc:    netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Subject:    Re: New IPv6 Draft Implementation


On Thu, 11 Sep 2003, Shirley Ma wrote:

> I am going to implement the support for the new IP MIBs draft for IPv6
MIBs
> only.
>
> Below is the draft link:
>
> http://www.ietf.org/internet-drafts/draft-ietf-ipv6-rfc2011-update-03.txt
.
> I am going to start from
> ipv6nterfaceTable. Any thoughts about this?

We are really waiting for this :)
I don't know any existing implementation of SNMP agent with support for
most IPv6 MIBs (especially with IPv6 adresses included in OIDs), but that
is thing which I am really looking for.

Please inform us about Your results :)

Marcin Kaminski
6Net project
