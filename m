From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Thu, 27 Jan 2005 17:36:18 -0800
Message-ID: <41F99712.2030201@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com>	<20050121141820.7d59a2d1.davem@davemloft.net>	<41F186A8.9030805@hp.com>	<20050121204948.034b2510.davem@davemloft.net>	<41F55B93.6040603@hp.com>	<20050124124353.2f760e1a.davem@davemloft.net>	<41F98306.6070804@hp.com> <20050127165707.250ee514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050127165707.250ee514.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 27 Jan 2005 16:10:46 -0800
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
> 
>>The other relates to the business of disabling TSO on a connection upon packet loss.
> 
> 
> There cannot possibly any compliance issues resulting from turning
> off an optimization in the face of packet loss.

I was a bit vague - compliance with the benchmark run and report rules, not with 
RFC's.

>>Internet connected systems experience non-trivial packet loss rates and so if TSO 
>>disabled upon packet loss it means a given benchmark result using TSO deviates 
>>even more from reality than one without TSO.
> 
> 
> And running the benchmark over a local gigabit subnet doesn't deviate
> from what Internet connected systems can expect to achieve how-so?

Benchmarking, not logic...

> Oh you mean I really can get 60,000 web or database connections a second
> when the users are over modems half-way across the planet?  Give me a
> break...

If there are enough users :)

> Anyways, see my other posting, we'll be able to keep TSO enabled in
> the face of packet loss, but that is an optimization not a correctness
> fix.

Cool.

rick jones
