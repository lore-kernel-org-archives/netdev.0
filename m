From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:37:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409152337.i8FNbDqG026335@guinness.s2io.com>
References: <Xine.LNX.4.44.0409151914400.32649-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'James Morris'" <jmorris@redhat.com>, "'John Heffner'" <jheffner@psc.edu>
In-Reply-To: <Xine.LNX.4.44.0409151914400.32649-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: James Morris [mailto:jmorris@redhat.com] 
> Sent: Wednesday, September 15, 2004 4:16 PM
> To: John Heffner
> Cc: Netdev; leonid.grossman@s2io.com
> Subject: Re: The ultimate TOE design
> 
> On Wed, 15 Sep 2004, John Heffner wrote:
> 
> > The other (much nicer) solution to case (b) is to just USE 
> A BIGGER MTU.
> > 1500 bytes is ridiculously small.  Even with a 9k MTU, the 
> benefits of 
> > TOE or TSO are nearly vanishing.
> 
> Do you have any figures on (large) MTU size vs performance on 
> a current commidity system?

It's very system-dependent. Say on 2-way Xeon our card goes from ~2Gbps to
~6Gbps, on 64-bit systems the delta is obviously less.

For 9k MTU, the delta goes down of course but it is still ~10% on 2.6
systems - say on 2-way Opterons we go from 7Gbps to 7.6Gbps.

Leonid

> 
> 
> - James
> --
> James Morris
> <jmorris@redhat.com>
> 
> 
