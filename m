From: Jiri Benc <jbenc@suse.cz>
Subject: Re: dscape git
Date: Tue, 18 Jul 2006 18:31:33 +0200
Message-ID: <20060718183133.2ebbec1e@griffin.suse.cz>
References: <20060717151555.28384.qmail@web60718.mail.yahoo.com>
	<20060717161439.38118.qmail@web60711.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Erik Mouw <erik@harddisk-recovery.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:5342 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751362AbWGRQbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 12:31:36 -0400
To: Tomas Winkler <tomas_bw@yahoo.com>
In-Reply-To: <20060717161439.38118.qmail@web60711.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Jul 2006 09:14:39 -0700 (PDT), Tomas Winkler wrote:
> Hmm, I've missed the second part of you email. 
> The solution you've suggested has worked. 
> Thanks
> Anyhow if this is a problem of sync then it last for 2
> days already.

This is because I'm using Linus' repository as a reference repository to
save space on kernel.org. Use --reference parameter as suggested.

However, if you are new with git I need to warn you: it's not easy to
track my tree. I rebase it frequently and it contains several branches,
some of whom disappear and reappear from time to time. This means you
cannot always simply pull from my tree to obtain updates (for a
solution, see below).

Note that it's always safe to try pulling (git-pull
git://git.kernel.org/.../dscape.git). If I haven't rebased the tree it
will succeed; if the tree was rebased it will fail, give you error
message and leave your tree in a state it was before.

If the pull fails, you can re-clone the tree. But it is time and
bandwidth consuming, so it is not recommended.


 === How to track dscape.git tree ===

1. Cloning the tree

1.1. Clone John Linville's wireless-dev.git tree:
git-clone git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

1.2. Create a new branch named 'dscape':
git-branch dscape

1.3. Checkout your new 'dscape' branch:
git-checkout dscape

1.4. Pull from 'master' branch of dscape.git tree (in the rare case when
this fails with a conflict, send me a note, I'll fix that):
git-pull git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master

1.5. You may pull from other branches of dscape.git tree now (e.g.
'devel' branch may be interesting). Be aware that branches other than
'master' may contain highly experimental code.

2. Updating the tree

2.1 Try pulling from 'master' branch of dscape.git tree:
git-pull git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master

2.2 If this succeeded (message informing you that merge was successful
or there was nothing to merge), you're done (and don't follow next
steps). If this didn't succeed, you need to recreate your 'dscape'
branch - follow next steps.

2.3 Checkout 'master' branch of your tree:
git-checkout master

2.4 Delete 'dscape' branch:
git-branch -D dscape

2.5 Pull from John Linville's tree (optional, but will speed up things
on next update):
git-pull git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

2.6 Continue from step 1.2.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
