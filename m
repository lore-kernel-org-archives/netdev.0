From: Rik van Riel <riel@conectiva.com.br>
Subject: multipath routing doesn't work with netlink
Date: Mon, 28 Oct 2002 14:10:24 -0200 (BRST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44L.0210281407540.22494-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Am I doing something wrong or is there a kernel bug that
prevents multipath routing from working with NETLINK ?

# ip route add default via 10.0.16.1
# ip route add default via 10.0.17.2
RTNETLINK answers: File exists
# route add default gw 10.0.17.2
#

... of course, this last command just works and results in
a routing table like this:

# ip route
10.0.16.0/21 dev eth0  proto kernel  scope link  src 10.0.17.3
127.0.0.0/8 dev lo  scope link
default via 10.0.17.2 dev eth0
default via 10.0.16.1 dev eth0

Is there a fundamental reason that iproute2 (using NETLINK) should
fail here, or is this a bug for which patches will be accepted ?

regards,

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/
