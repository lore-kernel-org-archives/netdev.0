From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: rwlock recursion on CPU#0, netfilter related?
Date: Sun, 25 Sep 2005 13:58:34 +0300
Message-ID: <20050925105834.GA15243@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just to get a wider audience, somewhere between 2.6.13-git4 and current 
(2.6.14-rc2-git4 is the last one I tested, which seems to have some
fixes in this are wrt. git3, but problem remains) my x86_64
crashes quite quickly after boot. Using Fedora devel kernels, I can
probably whip up a vanilla kernel if the maintainers in this area
prefer that.

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=167835

and

https://bugzilla.redhat.com/bugzilla/attachment.cgi?id=119228

apart from the crashes I get funny ping times on the kernels that
break when they're still up 
(64 bytes from 10.10.9.1: icmp_seq=0 ttl=255 time=4294971590968 ms)
