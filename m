From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC v2 0/7] introduce netfilter conntrack protos pernet functionality v2
Date: Wed, 11 Mar 2009 23:57:06 +0300
Message-ID: <20090311205706.141086138@gmail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: kaber@trash.net, davem@davemloft.net, daniel.lezcano@free.fr
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

here is a second request for comments on netfilter conntrack
protos per-net functionality. The following protos are covered
now: dccp, sctp, udplite, tcp, udp, icmp. So I would really
like to hear kind of comments (angry screams maybe :) on the
series.

To Patric:
Patric I decided to not assign sysctls data by iterative
fasion since it could lead for harder grep'ability, and
in case if order of "enum entries" changed the sysctls
will be silently broken. To make these assignments shorter
I've added ___PERNET_TO_DAT macro which has quite a small
lifetime inside sources. If you prefer to assign them
in for(;;) -- just say the word and I'll remake it :)

So please review and comment (if possible). Thanks!
(If someone could even test it -- it would be amaizing!
 I've been playing a bit with the series in qemu+lxc)

Hope I didn't miss anything.

Cyrill
