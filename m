From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:52:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.155251.25131382.davem@redhat.com>
References: <OFF1F6B3DC.30C0E5DE-ON85256D47.007AEFAF@us.ibm.com>
	<20030616.152745.124055059.davem@redhat.com>
	<3EEE4880.3080505@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, stekloff@us.ibm.com, janiceg@us.ibm.com,
   jgarzik@pobox.com, lkessler@us.ibm.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3EEE4880.3080505@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Mon, 16 Jun 2003 15:45:20 -0700

[ I removed this kenistonj@us.ibm.com from the CC:, it bounces... ]

   I'd agree a lot of thought (and agreement :))has to go
   into this before changing minor nits and stuff, and not
   causing too much disruption..Evolution, as opposed to
   revolution ;).  I would hope that most wouldnt need changing..

There would be absolutely ZERO disruption if you guys would use you
brains and implement what you're actually trying to achieve, a system
event logging mechanism.

We have a message queueing mechanism using sockets, called netlink,
and you can make whatever actions in the kernel you think should be
monitored go and stuff messages into this system event netlink socket.

Then, you don't have to standardize a bunch of absolutely silly
strings (I mean, the concept is so incredibly stupid), you get events
that are in a precisely defined format going over this netlink socket.

Then whoever in userspace reads out the messages can interpret them
however the fuck it wants to.  It is then trivial to parse the
messages and filter them.  Furthermore, you could even transmit such
messages over a network connection to a remote logging server as-is.

And hey, look, for network links going up and down we have the hooks
already.  Funny that...
