From: Shirley Ma <xma@us.ibm.com>
Subject: Re: IPv6 MIB:ipv6PrefixTable implementation
Date: Tue, 2 Dec 2003 16:33:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD75AA082.D0EE04A4-ON87256DF1.00005FF4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi, Alexy,

> preferred time is not an attribute of a prefix at all,
> it is attribute of address, is not it? Unless the prefix is used
> to install local address it does not make sense, right?

The new IPv6 MIBs said that the preferred time is saved in the prefix
table,
not in the address table.
Also, not every onlink prefix is saved in the routing table, for example,
if there
is already a manual address configured for an interface with the same
prefix.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
