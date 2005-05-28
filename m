From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Sat, 28 May 2005 18:16:37 +0200
Message-ID: <20050528161637.GT15391@postel.suug.ch>
References: <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain> <20050527165935.GC15391@postel.suug.ch> <1117242749.6251.15.camel@localhost.localdomain> <20050528012810.GN15391@postel.suug.ch> <1117244893.6251.41.camel@localhost.localdomain> <20050528121827.GQ15391@postel.suug.ch> <1117296041.19563.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117296041.19563.6.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117296041.19563.6.camel@localhost.localdomain> 2005-05-28 12:00
> > I just tested both patches for about 30 minutes. Everything OK. Feel
> > free to apply the patches.
> 
> We have another problem. What tree is this against? Both patches have
> failures patching against latest davem and linus git trees.

It's against my davem-pending tree which should reflect the current
state of davem's tree so they _should_ apply on his side. In this
specific case you're probably missing the neighbour table patches.

Basically I produce diffs this way:

separate tree per patchset -> merge into  testing tree ->
testing period -.  merge into $person-pending -> extraction
of patches and submission.

I was trying to get some more quality control into my workflow,
so I started testing patches for 3-4 weeks to avoid fallouts
but apparently this is failing miserably at the moment due to
some broken scripts of mine.
