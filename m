From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Tue, 22 Feb 2005 14:10:36 -0800
Message-ID: <200502222211.j1MMBWDD006726@guinness.s2io.com>
References: <421BA741.4050201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Rick Jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>
In-Reply-To: <421BA741.4050201@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Rick Jones
> Sent: Tuesday, February 22, 2005 1:42 PM
> To: netdev@oss.sgi.com
> Subject: Re: Intel and TOE in the news
> 
> Leonid Grossman wrote:
> > No wait, "paste in" only packets that are already received when a 
> > traffic interrupt comes...
> 
> Ah, so it is ass-u-me-ing that there is little or no packet loss?

This is a reasonable assumption in a datacenter, isn't it :-)?
At any rate, no wait still - if the driver doesn't find the next sequence
(no matter if the packet is lost or it is just not received yet at the time
the driver is looking at the receive buffer) it will indicate the
accumulated RSO right away.
 
> 
> How about when the driver is polling instead of taking 
> interrupts?  Will the driver "see" the RSO 
> segment-in-progress or will it be hidden?

It doesn't matter what triggered the driver to wake up and look at the
receive buffer.
It will still see in real time the packets that have been received - no
matter if the interrupts for these packets arrived or not.

Leonid

> 
> rick jones
> 
> 
