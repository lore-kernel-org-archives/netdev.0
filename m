From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 17:07:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE5BA8.8000601@us.ibm.com>
References: <OFF1F6B3DC.30C0E5DE-ON85256D47.007AEFAF@us.ibm.com>	<20030616.152745.124055059.davem@redhat.com>	<3EEE4880.3080505@us.ibm.com> <20030616.155251.25131382.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, stekloff@us.ibm.com, janiceg@us.ibm.com,
   jgarzik@pobox.com, lkessler@us.ibm.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030616.155251.25131382.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> There would be absolutely ZERO disruption if you guys would use you
> brains and implement what you're actually trying to achieve, a system
> event logging mechanism.

> We have a message queueing mechanism using sockets, called netlink,
> and you can make whatever actions in the kernel you think should be
> monitored go and stuff messages into this system event netlink socket.

I should clarify here that I was speaking strictly for my lonesome sorry
self :), and have no knowledge of what the state of the various
RAS projects currently are, and the approaches they are trying..
For all I know, they may be currently trying precisely that..

Janice's patch is the first I've seen in this area (Luckily,
most of the time they keep me in a cave :) :)), and I do
appreciate *something* being done in this area, it seemed a
good start and really, I dont care how its implemented, I'll
leave that to the folks who have spent longer than the
8 mins I currently have on it..

> Then, you don't have to standardize a bunch of absolutely silly
> strings (I mean, the concept is so incredibly stupid), you get events
> that are in a precisely defined format going over this netlink socket.

Well, right now, thats all we have, right? Silly strings? But
thats not really my position, which is more like:
Whatever! Whatever! Somebody! Make it so! :) :).

> Then whoever in userspace reads out the messages can interpret them
> however the fuck it wants to.  It is then trivial to parse the
> messages and filter them.  Furthermore, you could even transmit such
> messages over a network connection to a remote logging server as-is.
> 
> And hey, look, for network links going up and down we have the hooks
> already.  Funny that...

OK, that is a good idea.. :)

thanks,
Nivedita
