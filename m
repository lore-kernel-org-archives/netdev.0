From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: 28 Dec 2004 08:27:52 -0500
Message-ID: <1104240471.1090.61.camel@jzny.localdomain>
References: <20041219203050.GK17998@postel.suug.ch>
	 <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain>
	 <20041220200739.GX17998@postel.suug.ch> <41C7F833.4000909@trash.net>
	 <20041222003142.GB7884@postel.suug.ch>
	 <1103722366.1089.75.camel@jzny.localdomain>
	 <20041222142637.GE7884@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041222142637.GE7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-22 at 09:26, Thomas Graf wrote:
> * jamal <1103722366.1089.75.camel@jzny.localdomain> 2004-12-22 08:32
> > On Tue, 2004-12-21 at 19:31, Thomas Graf wrote:
> > > * Patrick McHardy <41C7F833.4000909@trash.net> 2004-12-21 11:17
> > > > Could you make your patchset available somehow ?
> > > 
> > > http://people.suug.ch/~tgr/patches/queue/
> > > 
> > > Unfinished and untested.
> > 
> > I just took a quick glimpse. 
> > 
> > 1)Recall: Policer will have to die at some point - only reason for its
> > existence is for backward compat.
> > New iproute2 code sooner than later stop using that inteface so we can
> > kill it. I suspect we can kill it in a year or two and definetely the
> > day 2.7 comes out.
> 
> I fully agree. The patchset looks like a beautification but it isn't.
> Its main purpose is to make changing consistent again. 

Except there is a continous stream of patches to cleanup cleanups ;->
Thats where the cosmetics definition comes in.
Lets just do it right and get it over with.

> I tried
> achieving this with the existing API and the ifdef hell got horrible
> and ended up having over 60 lines of redundant code per classifier.
> I would rather be implementing new fancy stuff but fixing the existing
> issues comes first.
> 
> > 2) The name tcf_attrs doesnt sound right - attributes are normally
> > data pieces not methods. Cant think of a good name.
> 
> I feel the same, I was thinking of extensions but wasn't pleased either.
> Suggestions appreciated.
> 
> > 3) What can i say? dang - this indev thing is getting out of control ;->
> 
> Too late, it's there, we must maintain it ;->
> 

I think needs to be fixed. Theres a clear bold warning that it would
die. We shouldnt keep building more walls and adding gardens around it.


> 
> > I think its time we did this right than defering.
> 
> Indeed, what about this: I'll try and do a proposal on a new
> generic matching layer holding the action bits and providing
> backward compatibility to police/indev. We can then build the
> metadata match on top of it.

Ok, waiting to see this. Post it on the list.

cheers,
jamal
