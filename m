From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 17:04:23 -0800
Message-ID: <42378617.3080600@hp.com>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>	<423764A3.8030201@pobox.com>	<20050315150809.579c5e85.akpm@osdl.org> <20050315165345.735573de.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com, netdev@oss.sgi.com,
        christoph@graphe.net, nirajk@calsoftinc.com, christoph@lameter.com,
        Shai@Scalex86.org
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050315165345.735573de.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> These loopback driver SMP optimizations are starting to really
> driver me crazy.

Correct or not, I suspect there are a non-trivial number of folks out there who 
use loopback performance as an indicator of over the network performance or at 
least of stack path length (less driver).  particularly when they have only one 
system and want to make quick (and so worth all the time they put into it) 
comparisons between OSes.

Perhaps that is a driver-ing (since punning drive/driver seems to be the order N 
squared of the day) force behind the changes?

rick jones
