From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 17:49:22 -0800
Message-ID: <423790A2.2000906@hp.com>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>	<423764A3.8030201@pobox.com>	<20050315150809.579c5e85.akpm@osdl.org>	<20050315165345.735573de.davem@davemloft.net>	<42378617.3080600@hp.com> <42378A8D.7090801@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, christoph@graphe.net, nirajk@calsoftinc.com,
        christoph@lameter.com, Shai@Scalex86.org
To: netdev@oss.sgi.com
In-Reply-To: <42378A8D.7090801@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Rick Jones wrote:
> 
>>> These loopback driver SMP optimizations are starting to really
>>> driver me crazy.
>>
>>
>>
>> Correct or not, I suspect there are a non-trivial number of folks out 
>> there who use loopback performance as an indicator of over the network 
>> performance or at least of stack path length (less driver).
> 
> 
> I hope not the former. Given that loopback performance is
> *significantly* faster than network performance, increasing the
> performance of the loopback driver in these somewhat artificial
> ways (that differ from the real network device path) simply
> *increases* the inaccuracy of their testing and the conclusions
> they can draw from it ;).

I suspect the idea is that if loopback on Platform A is faster than loopback on 
Platform B, then over the network will be faster (or at least more efficient) on 
Platform A than it is on Platform B.

It is indeed fraught with numerous pitfalls - different MTU's, shorticircuting 
at different places etc etc.

I do not claim to condone (even if I'm sometimes forced into that situation 
myself :( ) merely to explain.

As for the 512 CPU machine mentioned in another message, at the rate cores per 
die may increase over the next few years, that may not really be all that large 
a box... :)

rick jones
