From: Petr Baudis <pasky@ucw.cz>
Subject: Re: Re: networking bugs and bugme.osdl.org
Date: Sun, 20 Jul 2003 18:46:09 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030720164609.GH12132@pasky.ji.cz>
References: <20030629.151302.28804993.davem@redhat.com> <17280000.1056940541@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk,
	greearb@candelatech.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Content-Disposition: inline
In-Reply-To: <17280000.1056940541@[10.10.2.4]>
List-Id: netdev.vger.kernel.org

Dear diary, on Mon, Jun 30, 2003 at 04:35:44AM CEST, I got a letter,
where "Martin J. Bligh" <mbligh@aracnet.com> told me, that...
> --"David S. Miller" <davem@redhat.com> wrote (on Sunday, June 29, 2003 15:13:02 -0700):
..snip..
> > The greatest tools in the world aren't useful if people don't want
> > to use them.
> > 
> > Nobody wants to use tools unless it melds easily into their existing
> > daily routine.  This means it must be email based and it must somehow
> > work via the existing mailing lists.  It sounds a lot like what I'm
> > advocating except that there's some robot monitoring the list
> > postings.
> 
> Agreed, the interface could be better - we're working on it. It won't
> be totally change free, but it could be better integrated. Feedback is
> very useful, though it helps a lot of you can pinpoint what's the 
> underlying issue rather than "this is crap". Better email integration
> is top of the list, starting with sending stuff out to multiple people
> when filed, not a single bottleneck point.

Actually, it's not difficult to make Bugzilla to do things like sending out ALL
bugs updates emails to certain email adress(es), on a global basis or
per-module. Also, it is relatively easy to make Bugzilla _accept_ bugs updates
through email, from additional comments (+ attachments) to
status/priority/target/... changes.

It works quite nicely for us (ELinks) and it took just few hours to set up
properly (we had to touch the BZ sources, but just a little, the rest are
external support scripts). What is missing is some email interface for querying
the database (shouldn't be difficult to do, though), but if you just want to
file/update bugs, all you need is to:

* have the new bugs posted on the mailing list
* keep bugzilla in the cc list through the whole thread, as long as it's
relevant at least ;-)
* don't remove [Bug 12345] from the subject

If Martin would like some know-how about how to set things up, I could share
what we've done with him.

Kind regards,

-- 
 
				Petr "Pasky" Baudis
.
Perfection is reached, not when there is no longer anything to add, but when
there is no longer anything to take away.
	-- Antoine de Saint-Exupery
.
Stuff: http://pasky.ji.cz/
