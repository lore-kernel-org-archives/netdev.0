From: kuznet@ms2.inr.ac.ru
Subject: Re: [Issues] Implementation for IPv6 MIB:ipv6PrefixTable
Date: Fri, 24 Oct 2003 21:59:27 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310241759.VAA16832@yakov.inr.ac.ru>
References: <20031024044708.236f0d22.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com, netdev@oss.sgi.com, davem@redhat.com
In-Reply-To: <20031024044708.236f0d22.davem@redhat.com> from "David S. Miller" at Oct 24, 2003 04:47:08 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> First, do you think it's a good idea to save all prefix objects in routing
> table?

Those which are on-link, of course.


> Second, where is the best location for the off-link prefix, on-link flag 0
> prefix to be saved?

Do you really think off-link prefixes are to be saved? Prefix in use is onlink
by defintion, so just return 1 in these bit and ignore off-link prefixes
completely, they are meaningless, are not they?


> Third, do you think it's a good idea to implement a prefix table/per
> interface in the kernel?

Well, if SNMP is going to be used as a tool to snoop ndisc promiscuously
(which seems to be the case if it shows inforrmation about offlink prefixes),
then it is definitely not a kernel task.

Alexey
