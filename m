From: Richard Guy Briggs <rgb@redhat.com>
Subject: v6 superceded it [was: Re: [PATCH][v5] netlink: have netlink
 per-protocol bind function return an error code.]
Date: Wed, 26 Mar 2014 16:09:22 -0400
Message-ID: <20140326200922.GK28666@madcap2.tricolour.ca>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
 <5bf7c2b8ad25b31bb34ae00f5fe6ec7f5d653f4b.1395693533.git.rgb@redhat.com>
 <20140326.155258.685120737486107362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140326.155258.685120737486107362.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/03/26, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Mon, 24 Mar 2014 16:59:23 -0400
> 
> > +				if (err)
> > +					if (!nlk->portid)
> > +						netlink_remove(sk);
> > +					for (int undo = 0; undo < i; undo++)
> > +						if (nlk->netlink_unbind)
> > +							nlk->netlink_unbind(undo);
> > +					return err;
> 
> Take a good long stare at that code block for a while.
> 
> Looks like you forgot the braces to delineate the code block.

Did you notice all the attempts to send a corrected patch?  v6 finally
got it right (sent Monday).  Sorry for all the noise.  Serve me right
for not sitting on my hands before sending the email for a bit while I
checked it.

> This also means you really haven't tested this patch :-)

It was tested, but the patched code wasn't actually checked in.  It was
still in my tree.  I ran "git commit --amend" more than once, forgetting
the "-a", and didn't carefully enough inspect the resulting patch.

> Please also DO NOT declare local variables in a for() statement,
> this is not c++.

It is above the for now (also in v6).

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
