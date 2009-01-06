From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 05 Jan 2009 20:49:34 -0800 (PST)
Message-ID: <20090105.204934.65827705.davem@davemloft.net>
References: <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain>
	<20090105.201530.195720489.davem@davemloft.net>
	<alpine.LFD.2.00.0901052029220.3057@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754466AbZAFEtp@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0901052029220.3057@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Jan 2009 20:37:58 -0800 (PST)

> > The default is extremely strict, which makes me check things out by
> > hand.  That's good, but as I add the change by hand after verifying
> > it's sanity I often make mistakes that result in things like the above
> > missed delete, so if I could ask git to be non-strict it would help me
> > out a lot.
> 
> Yeah, I know, "git am" really is very strict, and sometimes annoyingly so. 
> But it _can_ be overridden. And if the other end uses git to generate the 
> patch, you can also do a three-way apply, which really tends to work. But 
> that requires that the patch have the SHA1 ID's of the original blobs (and 
> that you have those blobs - ie that the patch was really generated against 
> something you already had)

That wouldn't have helped me in this case at all.

I had 4 firmware patches to apply, each one had to add entries
to the same file.

The first patch had to be skipped.

So the second one, which is the first one I added (which is the acenic
bogon with the missed delete), is the one GIT wouldn't take but patch
would.

GIT blobs wouldn't give me any help here, but I suppose the fuzz stuff
might have.

I really just want stupid 'patch' behavior.  I'll check the result
carefully, so just apply the thing instead of making me jump through
hoops. :-)
