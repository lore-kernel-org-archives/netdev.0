From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Mon, 21 Feb 2005 08:52:13 -0800
Message-ID: <200502211653.j1LGr3DD025897@guinness.s2io.com>
References: <1108993498.1089.149.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, "'rick jones'" <rick.jones2@hp.com>,
        <netdev@oss.sgi.com>, "'Alex Aizman'" <alex@neterion.com>
To: <hadi@cyberus.ca>
In-Reply-To: <1108993498.1089.149.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of jamal
> Sent: Monday, February 21, 2005 5:45 AM
> To: Leonid Grossman
> Cc: 'Andi Kleen'; 'rick jones'; netdev@oss.sgi.com; 'Alex Aizman'
> Subject: RE: Intel and TOE in the news
> 

> > In other OS drivers we have an option to indicate a "packet train" 
> > that got received during an interrupt,
> 
> Explain what you mean by "packet train". If you mean a burst 
> of random packets that just happened to arrive back to back, 
> then it is not useful. NAPI already does a sufficently great 
> job at processing these by pulling them off the DMA ring and 
> processing to completion.

Yes, the question was with regards to the burst of random packets.
I agree that this may be not too useful and arguably doesn't warrant the
significant stack change. The reason I asked is that one of our engineers
was under impression (from reading Linux TCP/IP Stack book) that the feature
is already supported.

WRT to the burst of packets related to the same flow - we are hoping to be
able to collapse the burst into a single oversized frame and pass it to the
stack, this way no or very minimal changes to the stack will be needed. 
There is enough intelligence on the NIC to do that efficiently, we just need
to try and see how well this works.

Leonid 

> OTOH, if you mean a train of packets terminating at exactly 
> the same location i.e related to the same flow, then this 
> would be useful.
> I suspect the later would require extreme intelligence that 
> may not be suited for your NIC. 
> This leaves you with only nicecities of spliting a packet 
> into header/data which may allow for nice gather-scatter 
> techniques. Remains to be seen (in other words, proof is in 
> the pudding, make it - experiment and show that it tastes good).
> 
> cheers,
> jamal
> 
> 
> 
