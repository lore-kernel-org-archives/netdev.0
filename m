From: Ronghua Zhang <rz5b@cs.virginia.edu>
Subject: synchronization between bottom half and user context
Date: Tue, 3 Dec 2002 00:39:02 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212030038030.1334-100000@bobbidi.cs.virginia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can someone tell me when lock should be used to synchronize bh and user
context?

For examle: in tcp_accept(), lock_sock() is called to avoid any change
made by net_bh during its operation. But if tcp_accept() is called, it's
impossilbe that net_bh is also executing. (i think this is true for UP,
what about SMP?), then why need lock_sock()?

ronghua
