From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: The ultimate TOE design
Date: Thu, 16 Sep 2004 13:34:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409162034.i8GKYq39023185@guinness.s2io.com>
References: <4149BCE9.7040501@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@suse.de>, "'David S. Miller'" <davem@davemloft.net>,
        "'John Heffner'" <jheffner@psc.edu>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Nivedita Singhvi'" <niv@us.ibm.com>
In-Reply-To: <4149BCE9.7040501@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Nivedita Singhvi [mailto:niv@us.ibm.com] 
> Sent: Thursday, September 16, 2004 9:19 AM
> To: Leonid Grossman
> Cc: 'Andi Kleen'; 'David S. Miller'; 'John Heffner'; 
> netdev@oss.sgi.com
> Subject: Re: The ultimate TOE design
> 
> Leonid Grossman wrote:
> 
> > We can dream about benefits of huge MTUs, but the reality is that 
> > moving beyond 9k MTU is years away. Reasons - mainly 
> infrastructure, 
> > plus MTU above ~10k may loose checksum protection (granted, this 
> > depends whether the errors are simple or complex, and also this may 
> > not be a showstopper for some people).
> > Even 9k MTU is very far from being universally accepted, 
> eight years 
> > after our Alteon spec went out :-).
> 
> One other factor is TCP congestion control, and congestion 
> windows we obey. Most of the time, you just can't send that much.

It's a bit painful to setup, but in general with 9k jumbos and TSO we were
able to get close to pci-x 133 limit - both in LAN and WAN tests.
Leonid

> 
> thanks,
> Nivedita
> 
> 
