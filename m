From: Eric Lemoine <Eric.Lemoine@Sun.com>
Subject: EmbryonicRsts between two Linux boxes
Date: Fri, 21 Mar 2003 19:17:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030321181706.GD1103@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have three Linux boxes on the same physical network. One runs a web
server (webfs) and the other two run an HTTP traffic generator. Under 
high load, with many simultaneous open connections (~1000) one of the
clients gets a TCP RST ("read: Connection reset by peer").

netstat -s on the server box gives:

...

TcpExt:
    3002 resets received for embryonic SYN_RECV sockets

...

Which, if I understand correctly, means that the server TCP stack
receives a SYN|ACK or a RST|ACK from one of the clients for a 
SYN_RECV socket.

How can this happen?

Thx.

PS: there's 100ms network latency between the server and the clients
(emulated by NistNet). And I want to saturate the server. That's the
reason I need so many simultaneous connections.

-- 
Eric
