From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 17:23:25 -0800
Message-ID: <42378A8D.7090801@us.ibm.com>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>	<423764A3.8030201@pobox.com>	<20050315150809.579c5e85.akpm@osdl.org> <20050315165345.735573de.davem@davemloft.net> <42378617.3080600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
        jgarzik@pobox.com, netdev@oss.sgi.com, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42378617.3080600@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:

>> These loopback driver SMP optimizations are starting to really
>> driver me crazy.
> 
> 
> Correct or not, I suspect there are a non-trivial number of folks out 
> there who use loopback performance as an indicator of over the network 
> performance or at least of stack path length (less driver).

I hope not the former. Given that loopback performance is
*significantly* faster than network performance, increasing the
performance of the loopback driver in these somewhat artificial
ways (that differ from the real network device path) simply
*increases* the inaccuracy of their testing and the conclusions
they can draw from it ;).

thanks,
Nivedita
