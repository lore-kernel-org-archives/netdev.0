From: YongHan Lee <y_h_lee@yahoo.com>
Subject: Writing Kernel Module to get Kernel Routing Table Information
Date: Mon, 12 Sep 2005 09:51:53 -0700 (PDT)
Message-ID: <20050912165153.51505.qmail@web34211.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: y_h_lee@yahoo.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear Linux-Networking Maintainer,

I am a student of EPFL in Switzerland and do a
semester project in networking.
My subject is "ipv6 multipath AODV routing
implementation".

To achieve my goal I would like to program a kernel
module which allows/enables
multipath routing. This means, if I have several
routes to one destination (but
different next hops) in the kernel routing table, then
I want to choose a route
entry with the desired next hop and not necessary the
first route entry. Since I
do not know well the kernel architecture, especially
the kernel networking
section, I do not know if and how it is possible.

My first idea was to use netfilter for ipv6, but the
multiple routing table with
marks are only implemented for ipv4.
https://lists.netfilter.org/pipermail/netfilter/2005-August/062252.html

And now I try to write a Kernel module which should
retrieve all route entries
from the kernel routing table (fib6_node, rt6_info or
dst_entry struct) by
comparing the destination address, source address and
next hop address with
those of the ip packet. This happens at POST ROUTING
hook. Afterwards, I would
change the destination (struct dst_entry) of the
sk_buff struct of the ip
packet. The problem is not to get the next hop address
of the ip packet.
I have started to write my kernel module, but it was
not able to get the route
entries from the kernel routing table, because a lot
of the functions are
static.
I wanted to iterate the fib6_nodes from the root (like
fib6_lookup(&ip6_routing_table, daddr, saddr) [from
ip6_fib.c]), but the kernel
returns me:
Sep 12 17:31:34 m66533pp kernel: kaodv: Unknown symbol
fib6_lookup
Sep 12 17:31:34 m66533pp kernel: kaodv: Unknown symbol
ip6_routing_table
even they are defined in kallsyms and I included the
ip6_fib.h file.

I would be very glad if you could give me some helps
or advises (how it is
possible or my idea is totally impossible). Some links
to architecture of kernel
routing table would be already a great help for me.

I would like to thank you in advance for your help.

yours faithfully,

Yong-Han Lee





		
__________________________________ 
Yahoo! Mail - PC Magazine Editors' Choice 2005 
http://mail.yahoo.com
