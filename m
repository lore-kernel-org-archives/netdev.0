From: Andi Kleen <ak@suse.de>
Subject: Re: zero window probes on linux (fwd)
Date: Wed, 14 Apr 2004 14:10:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414141010.267a6204.ak@suse.de>
References: <20040414134106.3f36c629.ak@suse.de>
	<200404141205.RAA06111@shilpa.india.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Praveen Kumar Amritaluru <praveen@india.hp.com>
In-Reply-To: <200404141205.RAA06111@shilpa.india.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Apr 2004 17:35:33 +0530 (IST)
Praveen Kumar Amritaluru <praveen@india.hp.com> wrote:

> > > > > 	This  seems  to be a bug.  Has it been  already  fixed in  later
> > > > > 	kernel versions or is this how it is intended to remain?
> > > > 
> > > > iirc this was intentional. The RFC suggested method doesn't work when talking to 
> > > > some stacks.
> > > > 
> > > 
> > > 	But  that  cannot  be  valid  enough   justification  for  doing
> > > 	something against RFC right?
> > 
> > Of course it is. Welcome to the real world. RFC1122 has a lot of bugs and sometimes
> > does not describe really implemented practice (e.g. BSD set the defacto standard
> > in many behaviours and it does not always follow 1122) 
> 
> 	So do u consider mandating definition of zero-window probes as defined
> 	in RFC793 as a bug in RFC1122?

They are not directly a bug, but are just not what the world standardized on. 

 
> 	Or else r u saying this bug is introduced in linux to take care of
> 	faulty stacks existing in the world. zero-window probes as defined
> 	in RFC1122 is not buggy right?

Implementing a production network stack is not about following some standard to the 
letter, but about interoperating with real implementations in a useful matter.
Linux does that.

-Andi
