From: n.srinivasan@vsnl.net
Subject: Regarding Concurrent accept() in Linux
Date: Mon, 07 Jun 2004 21:20:56 +0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <f389943f38a35b.f38a35bf389943@vsnl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-language: en
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I read on the net that Linux supports concurrent accept(). Does this mean that two threads can call accept() on the same socket and dequeue a connection almost in parallel? Having looked at the code (2.6.6), I guess tcp_accept() routine grabs a lock before dequeueing the eager connection. I guess this is the point it gets serialised. If this is the case, there isnt much difference from the BSD code. Or is concurrent accept() a different feature altogether.

Cheers,

Cheenu.
