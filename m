From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 13:58:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B220F.4040102@us.ibm.com>
References: <1096481023.8636.7.camel@localhost.localdomain>	<415AFB63.7010107@us.ibm.com> <20040929132247.227fffcd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929132247.227fffcd.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Nivedita, it was you specifically who complained to me
> when I used a seperate BK tree for networking changes
> last month whilst Linus was away for 2 weeks.  You said

"complained" ? no, no, honestly, it was just a very polite
inquiry :) :)

> And I have to warn people if they think that the churn is fast
> and the rate of change in the networking is high right now, you
> have seen absolutely nothing yet. :-)

yep, this is to some extent driving this, and things
like picking up the tso patches where we needed to
test prior to you checking them in.

Sure, we'd benefit from having fewer trees to test,
and since the -mm tree is already getting tested
and consuming the hw resources, we'd have benefited
from having the networking tree go into -mm. Hence
my previous inquiry to see if you could go through
-mm. If you're feeding to Linus immediately, then
we could just as well test mainline.

There is a need to have mainline stable, but that
can be solved by stretching out the bk snapshots and
increasing the number of rc releases so mainline
releases are fairly stable (something Andrew Morton
mentioned yesterday). That has been a separate
ongoing discussion among a lot of people.

Your point about there being a lot of other stuff
in -mm and it not being stable is taken, and it would
be nice to have a networking contained tree.

Which brings us to having your interim bk tree
available to test - which would be fine with me :)

What we're setting up is throwing the nightly
release onto 2 big boxes and running some heavy
duty networking stress tests.

All in the spirit of wanting to be helpful, honestly :).
Any suggestions welcome..

thanks,
Nivedita
