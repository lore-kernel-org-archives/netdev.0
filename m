From: Steve G <linux_4ever@yahoo.com>
Subject: Unaccepted Connections
Date: Mon, 7 Jul 2003 07:03:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030707140343.14852.qmail@web9602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I have a user space programming question and need some
ideas from networking gurus. I am working on a well known
inet daemon that listens for tcp connections and passes the
descriptor returned by listen() to a child program to
handle in the tcp/wait mode.

It turns out that many child programs error during their
startup and exit without accepting the connection
(linuxconf is one of them). The daemon that listens sees
the descriptor as readable and starts a new child...which
dies. This can loop forever.

The questions are: 

1) How can a parent process reliably determine that its
child has indeed accepted the connection? (ptrace is not a
good solution.)

2) Is it possible to tell anything about a connection that
has returned from listen but not yet accepted? For instance
the source IP address? Or checksum? Can recvfrom PEEK into
the packet?

Thanks,
Steve Grubb

__________________________________
Do you Yahoo!?
SBC Yahoo! DSL - Now only $29.95 per month!
http://sbc.yahoo.com
