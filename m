From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Tue, 24 May 2005 02:25:51 -0400
Message-ID: <4292C8EF.3090307@pobox.com>
References: <4292BA66.8070806@pobox.com> <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261200AbVEXG0J@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Tue, 24 May 2005, Jeff Garzik wrote:
> 
> 
>>Please pull the 'for-linus' branch from
>>
>>rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> 
> Is this really what you meant to do? There's seven merges there, none of
> which have _any_ information about _what_ you merged, because you've mixed
> everything up in one tree, so that there's absolutely no record of the
> fact that you actually had seven different repositories that you pulled..
> 
> That sucks, Jeff.
> 
> I don't understand why you don't use different trees, like you did with
> BK. You can share the object directory with the different trees, but the
> way you work now, it all looks like mush.
> 
> Even if you don't get confused youself, you sure are confusing everybody 
> else with it..

You are getting precisely the same thing you got under BitKeeper:  pull 
from X, you get my tree, which was composed from $N repositories.  The 
tree you pull was created by my running 'bk pull' locally $N times.

Ultimately, you appear to be complaining about:

* your own git-pull-script, which doesn't record the $2 (branch) 
argument in the commit message.

* the fact that my changelog includes the merge csets that were 
present-but-invisible by my BitKeeper submissions.  i.e. I lack a 
shortlog that filters out merge csets.



> Anyway, if you really want to work this way, with one big mushed-together
> thing that has different heads that you keep track of, can you _please_ at
> least make the commit message tell what you're doing. It's not a complex 

Hey, I didn't write git-pull-script, I just use it :)


> script, and you're definitely mis-using it as things stand now by 
> switching heads around inside one repository, and not telling other people 
> about it.

Switching heads around?  It sounds like you did not pull from the branch 
I mentioned.  This is how git-pull-script pulls from a branch:

git-pull-script \
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git\
  refs/heads/for-linus

	Jeff
