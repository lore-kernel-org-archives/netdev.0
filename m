From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 17:40:06 +0100
Message-ID: <20050221164006.GY31837@postel.suug.ch>
References: <20050220230713.GA62354@muc.de> <200502210332.j1L3WkDD014744@guinness.s2io.com> <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch> <1108994621.1089.158.camel@jzny.localdomain> <20050221141714.GV31837@postel.suug.ch> <1108996313.1090.178.camel@jzny.localdomain> <20050221153443.GW31837@postel.suug.ch> <1109000925.1076.3.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1109000925.1076.3.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1109000925.1076.3.camel@jzny.localdomain> 2005-02-21 10:48
> On Mon, 2005-02-21 at 10:34, Thomas Graf wrote:
> > Make sense but we probably have multiple packets in the stack if qdiscs are
> > involved. 
> 
> No - thats the problem. Theres always no more than one packet i.e only
> packet in flight except in the case of some hardware - which i pointed
> out as problematic in my SUCON presentation.

I read your slides again but I guess I'm missing the information you
provided in your speech. One of the disadvantages of organizing a
conference is that one can't listen to the speeches. ;->

> Maybe i should write a paper about this - i spent christmas collecting a
> lot of data using relayfs; 

Would be nice, or at least provide the data. I haven't done any data
collection execpt some basic data to check ematch performance depening
on the size of the evalation tree, i.e. the number of ematches attached
to a classifier to find out wehther further optimizations are needed.

So basically you're telling me that it doesn't make a difference for a
full qdisc to dequeue in single steps or in batches?
