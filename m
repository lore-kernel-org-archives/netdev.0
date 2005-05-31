From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Tue, 31 May 2005 05:39:51 -0400
Message-ID: <1117532391.6134.13.camel@localhost.localdomain>
References: <20050527141320.GQ15391@postel.suug.ch>
	 <1117206091.6383.73.camel@localhost.localdomain>
	 <20050527151913.GA15391@postel.suug.ch>
	 <1117209466.6383.106.camel@localhost.localdomain>
	 <20050527165935.GC15391@postel.suug.ch>
	 <1117242749.6251.15.camel@localhost.localdomain>
	 <20050528012810.GN15391@postel.suug.ch>
	 <1117244893.6251.41.camel@localhost.localdomain>
	 <20050528121827.GQ15391@postel.suug.ch>
	 <1117296041.19563.6.camel@localhost.localdomain>
	 <20050528161637.GT15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050528161637.GT15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-28-05 at 18:16 +0200, Thomas Graf wrote:
> * jamal <1117296041.19563.6.camel@localhost.localdomain> 2005-05-28 12:00
> > > I just tested both patches for about 30 minutes. Everything OK. Feel
> > > free to apply the patches.
> > 
> > We have another problem. What tree is this against? Both patches have
> > failures patching against latest davem and linus git trees.
> 
> It's against my davem-pending tree which should reflect the current
> state of davem's tree so they _should_ apply on his side. In this
> specific case you're probably missing the neighbour table patches.


Now you really have to send some swiss chocolate over ;->
It still doesnt apply to Davems latest tree.

> Basically I produce diffs this way:
> 
> separate tree per patchset -> merge into  testing tree ->
> testing period -.  merge into $person-pending -> extraction
> of patches and submission.
> 

Almost very close to what i do - which could be improved or you keep a
few hundred trees. Jeff Garzik (some email to netdev with a HOWTO ) was
talking about some new scheme where instead of trees you use branches of
the same tree. I didnt quiet follow his trick.

> I was trying to get some more quality control into my workflow,
> so I started testing patches for 3-4 weeks to avoid fallouts
> but apparently this is failing miserably at the moment due to
> some broken scripts of mine.

I think the problem in this case was you had already commited to that
tree your changes that you sent to Dave. And the tree you were using as
a base for generating the patch was only something you and Dave know
about.

cheers,
jamal
