From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 10:48:45 -0500
Message-ID: <1109000925.1076.3.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch>
	 <1108994621.1089.158.camel@jzny.localdomain>
	 <20050221141714.GV31837@postel.suug.ch>
	 <1108996313.1090.178.camel@jzny.localdomain>
	 <20050221153443.GW31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050221153443.GW31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 10:34, Thomas Graf wrote:
> * jamal <1108996313.1090.178.camel@jzny.localdomain> 2005-02-21 09:31
> > 
> > I have done the experiments and even posted the patches on netdev last
> > year to batch on enqueue. 
> 
> Right, I slightly remember. I have a head like a sieve. Can you
> remmeber the subject of the post? I can't find it in the archive.
> 

I cant remember - patches are on another machine; the last time i posted
was with some folks from .it who were trying to improve routing
perfomance. 

> > Infact performance goes down when you batch in some cases depending on
> > the hardware used. My investigation shows that if you have a fast CPU
> > and a fast bus, theres always only one packet in flight within the
> > stack. Batching by definition requires more than one packet.
> 
> Make sense but we probably have multiple packets in the stack if qdiscs are
> involved. 

No - thats the problem. Theres always no more than one packet i.e only
packet in flight except in the case of some hardware - which i pointed
out as problematic in my SUCON presentation.

Maybe i should write a paper about this - i spent christmas collecting a
lot of data using relayfs; 

cheers,
jamal
