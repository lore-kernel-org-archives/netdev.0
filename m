From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: 04 Oct 2004 10:59:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096901984.1073.9.camel@jzny.localdomain>
References: <20041003213124.GG14344@postel.suug.ch>
	 <20041003213954.GI14344@postel.suug.ch>
	 <20041003161436.50293f9a.davem@davemloft.net>
	 <20041003233647.GN14344@postel.suug.ch>
	 <1096852582.1046.378.camel@jzny.localdomain>
	 <20041004125300.GA15898@postel.suug.ch>
	 <1096896256.1072.4.camel@jzny.localdomain>
	 <20041004141532.GB15898@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041004141532.GB15898@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-10-04 at 10:15, Thomas Graf wrote:
> * jamal <1096896256.1072.4.camel@jzny.localdomain> 2004-10-04 09:24
> > What you need is to replace the HZ/4 in the creation and execution
> > of the timer with a constant. And that the value of said constant would
> > be preferably in the 250ms range.
> 
> HZ/4 == 250ms works except for HZ=122 (~246ms) and HZ=50 (~240ms).

is that bad to let those have a slight different innacurate value?
BTW wasnt there a jiffies2ms converter somewhere that we could use?
I thought i saw something posted of that nature recently.

>  I don't
> know how you think it is possible to find a constant around 250ms which
> works for all HZ values. The problem gets even minor if we do
> (HZ<<idx)/4 instead of (HZ/4)<<idx in which the inaccuracy only happens
> if idx is 0, i.e. interval == -2. 

There should really be no difference between the two;-> you realize /4
is merely <<2 ?

cheers,
jamal
