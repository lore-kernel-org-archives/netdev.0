From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: is sk->reuse truly a boolean?
Date: Tue, 20 May 2003 12:57:45 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520155744.GE801@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From what I see in the code and from references in, for instance, Unix
Network Programming (W. Richard Stevens) it is, but then how can this work?

net/ipv4/tcp_ipv4.c, line 265

                if (sk->reuse > 1)
                        goto success;

In net/core/sock.c, setsockopt it just assigns 1 or 0, i.e. if userspace
passes > 1 it becomes 1, is this the intended behaviour? I think we have a 
bug in tcp_ipv4 or in core/sock.c 8)

Comments?

- Arnaldo
