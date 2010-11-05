From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Fri, 5 Nov 2010 18:01:30 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011051749230.17746@swampdragon.chaosbits.net>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>  <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>  <1288938640.3234.12.camel@edumazet-laptop>  <1288940146.18440.55.camel@Joe-Laptop>
 <1288941371.3234.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1527753567-1288976490=:17746"
Cc: Jiri Kosina <trivial@kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288941371.3234.31.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1527753567-1288976490=:17746
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 5 Nov 2010, Eric Dumazet wrote:

> Le jeudi 04 novembre 2010 à 23:55 -0700, Joe Perches a écrit :
> > On Fri, 2010-11-05 at 07:30 +0100, Eric Dumazet wrote:
> > > I had _one_ patch, waiting that David actually had vzalloc() in its tree
> > > before sending it.
> > 
> > Fine by me, use yours.
> 
> I dont care at all, only to say that David tree was not ready yet.
> 
> 
> > 
> > > Given Jesper Juhl was doing this work, could you please take another
> > > one, please ?
> > > For example, explaining him how to use other tools than "bash+egrep
> > > +manual inspection" as he mentioned in a previous mail.
> > 
> > Jesper Juhl was both pointed at the cocci docs and
> > given a cocci script.  He said he'd investigate it
> > when he could.  I trust he will get to it.
> > 
> 
> Yes, yet you posted patches, knowing he was working on the _same_
> subject.
> 
And I will get to look at cocci and spatch, they are definately tools that 
I want in my arsenal.

> I remember other occurrences of such behavior.
> 
> I find this behavior very unfriendly, time consuming, and not useful.
> 
> We try to work together, to increase our common knowledge, not to throw
> a bunch of patches "just because I know better than you"
> 

To be completely honest, I did get the feeling that the task I'd set for 
myself and was having fun doing in the little spare time I have got 
hijacked and I did waste about an hour and a half doing a few more 
cleanups before I saw the patchset on lkml.

But on the other hand, the most important thing is that it gets done, not 
who ends up doing it - especially since it's such a trivial cleanup, so I 
choose to see it as my initial patches just getting the ball rolling.

It would have been nice with at least an email along the lines of "I 
know how we can do all those patches in a jiffy, mind if I just go along 
and do that?", but I'll live. There's plenty of other stuff to do :-)


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--8323328-1527753567-1288976490=:17746--
