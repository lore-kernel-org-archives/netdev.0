From: "Hassan M. Jafri" <hjafri@ncsa.uiuc.edu>
Subject: TCP connections dropped
Date: Fri, 19 Sep 2003 12:16:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030919121408.00afd738@mail.ncsa.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kernel 2.4.19
glibc 2.2.5

I am running a parallel program on 170 nodes, with 2 processes on each
nodes. so 340 total processes. Each process has a TCP connection
established with every other process. So each process has 339 sockets in
ESTABLISHED state. The problem occurs when I try to write() on these
socket. The TCP connection gets dropped for some of the sockets of a few
processes as soon as they try to write to those socket. This problem,
however, does not occur, if I reduce the number of processes to less than
306 (305 TCP sockets/connections for each process).

Any ideas why connections are getting dropped?

Hassan

p.s All sockets are non-blocking and nagle is disabled.
