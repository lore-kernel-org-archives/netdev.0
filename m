From: John Heffner <jheffner@psc.edu>
Subject: Re: Bug-hunting
Date: Wed, 23 Feb 2005 15:00:10 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0502231453260.28189@dexter.psc.edu>
References: <421B4AB7.9030003@rapidforum.com> <20050222104448.31373a99.davem@davemloft.net>
 <421B8563.9030608@rapidforum.com> <20050222115114.0d0e568e.davem@davemloft.net>
 <421BBE7B.1050009@rapidforum.com> <20050222193000.404ae6d2.davem@davemloft.net>
 <421C5AC8.70601@rapidforum.com> <20050223112927.349550d0.davem@davemloft.net>
 <421CDD95.2020108@rapidforum.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421CDD95.2020108@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian,

Try looking at /proc/net/netstat while running.  If TCPMemoryPressures is
increasing, you are running out of TCP memory, and you would expect to see
your socket buffers shrinking.

  -John
