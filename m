From: Praveen Kumar Amritaluru <praveen@india.hp.com>
Subject: Re: zero window probes on linux (fwd)
Date: Thu, 15 Apr 2004 18:50:55 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404151320.SAA22825@shilpa.india.hp.com>
References: <20040414141010.267a6204.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040414141010.267a6204.ak@suse.de> from Andi Kleen at Apr "14," 2004 "02:10:10" pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > > > > 	This  seems  to be a bug.  Has it been  already  fixed in  later
> > > > > > 	kernel versions or is this how it is intended to remain?
> > > > > 
> > > > > iirc this was intentional. The RFC suggested method doesn't work when talking to 
> > > > > some stacks.
> > > > > 
> > > > 
> > > > 	But  that  cannot  be  valid  enough   justification  for  doing
> > > > 	something against RFC right?
> > > 
> > > Of course it is. Welcome to the real world. RFC1122 has a lot of bugs and sometimes
> > > does not describe really implemented practice (e.g. BSD set the defacto standard
> > > in many behaviours and it does not always follow 1122) 
> > 
> > 	So do u consider mandating definition of zero-window probes as defined
> > 	in RFC793 as a bug in RFC1122?
> 
> They are not directly a bug, but are just not what the world standardized on. 
> 
>  
> > 	Or else r u saying this bug is introduced in linux to take care of
> > 	faulty stacks existing in the world. zero-window probes as defined
> > 	in RFC1122 is not buggy right?
> 
> Implementing a production network stack is not about following some standard to the 
> letter, but about interoperating with real implementations in a useful matter.
> Linux does that.

	I checked the following vendor Operating Systems:

	HPUX, SunOS 5.8, FreeBSD 4.9.

	All of them send  zero-window  probes as per RFC1122.  If BSD is
	considered the defacto standard then why is linux deviating from
	BSD in this aspect?

	Do u mean to say  the  above  will  not  interoperate  with  the
	production  network stacks which u r talking.  BTW which r those
	production network stacks u r referring to?


	Is there  any  other  linux  mailing-lists  where I can get most
	appropriate response?

-Praveen


> 
> -Andi
> 
