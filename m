From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 03 Jan 2005 10:55:26 -0500
Message-ID: <1104767726.1049.591.camel@jzny.localdomain>
References: <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
	 <1104526311.1047.379.camel@jzny.localdomain>
	 <20050101121041.GR32419@postel.suug.ch>
	 <1104622164.1048.444.camel@jzny.localdomain>
	 <20050102000612.GU32419@postel.suug.ch>
	 <1104763012.1047.524.camel@jzny.localdomain>
	 <20050103150230.GC26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050103150230.GC26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-03 at 10:02, Thomas Graf wrote:

> > ok. I realize its optional - but i wouldnt even give the writter of
> > ematch the opportunity to write one. Want something more complex? write
> > a classifier.
> 
> A classifier is at least 300 lines and you lose the ability to use the
> logic relations.

Sure, but simpler-than-classifier is where we started ;->
I think in time we should revamp this a little more, but classifiers we
have today already we just cant get rid of them now. Over time, I agree 
we should revamp.
 
> > Again allowing for this may be overkill. Just send the same structure
> > the ematch needs in exactly the same form it needs it and you dont need
> > this. 
> 
> Compromise: If change/dump is not provided the api allocates and
> memcpy's itself resptively dumps m->data. Simple ematches don't have to
> care and can simple access m->data, more complex ematches can implement
> their own change/dump. Does that sound beter?

Yes, indeed. A copy instead of reference is owned by the classifier.
To me its a valid compromise. Dont want those matches to be shared
in any case. Also dont want user to know shit about TLVs.
Neither in the kernel, nor in user space. Simplicty.

Sorry, havent looked at the code yet. Is the patch you posted the same
as you have on the url earlier?

> > whats the .link for?
> 
> I use list.h to chain ematch_ops and it's better to have it initialized.

I relaized that - but should the user know anything about this?

cheers,
jamal
