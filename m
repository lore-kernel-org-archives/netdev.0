From: jamal <hadi@cyberus.ca>
Subject: RE: Intel and TOE in the news
Date: 21 Feb 2005 12:11:20 -0500
Message-ID: <1109005880.1076.77.camel@jzny.localdomain>
References: <200502211653.j1LGr3DD025897@guinness.s2io.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, "'rick jones'" <rick.jones2@hp.com>,
        netdev@oss.sgi.com, "'Alex Aizman'" <alex@neterion.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
In-Reply-To: <200502211653.j1LGr3DD025897@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 11:52, Leonid Grossman wrote:
>  
> WRT to the burst of packets related to the same flow - we are hoping to be
> able to collapse the burst into a single oversized frame and pass it to the
> stack, this way no or very minimal changes to the stack will be needed. 
> There is enough intelligence on the NIC to do that efficiently, we just need
> to try and see how well this works.

Indeed, would be nice to see what you come up with. I think there may be
value in sending one huge chunk packet which itself is actually a
collection of several independet packets when you have a huge amount of
small packets. The benefit being you amortize the cost of DMA setup.
But then you may need to be able to break them down in the driver; is
this what you are talking about?

cheers,
jamal
