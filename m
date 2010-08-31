From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Mon, 30 Aug 2010 21:42:09 -0700 (PDT)
Message-ID: <20100830.214209.45878329.davem@davemloft.net>
References: <20100706142542.d723903f.sfr@canb.auug.org.au>
	<20100831125738.7f18610b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com, gregkh@suse.de,
	James.Bottomley@suse.de
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100831125738.7f18610b.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 31 Aug 2010 12:57:38 +1000

> Can we have a fix for these please?  They make too much noise in the builds.

See below:

--------------------
Subject: Re: [GIT] Networking
From: David Miller <davem@davemloft.net>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Wed, 04 Aug 2010 13:41:15 -0700 (PDT)
X-Mailer: Mew version 6.3 on Emacs 23.1 / Mule 6.0 (HANACHIRUSATO)

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Aug 2010 12:06:47 -0700

> On Tue, Aug 3, 2010 at 8:38 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Another release, another merge window, another set of networking
>> changes to merge :-)
> 
> Ok, merged. But you should double-check my merge resolution fixes,

Will do, thanks a lot.

> I'm also a bit unhappy about how it introduces new warnings in very
> subtle ways.

Joe Perches presented patches to fix this (arguably always broken)
issue to James Bottomley and co. several weeks ago:

	http://marc.info/?l=linux-next&m=127882494322533&w=2

And it's been, in typical SCSI subsystem maintainer fastion, in
"stall" mode ever since.

In fact, when we noticed this problem, Joe Perches said he would only
post the patches to the SCSI folks if I would "deal" with James
Bottomley.  If it's to that point, well... I don't know what to say.

I know the warning is introduced by changes in my tree, but I
figured with weeks until the merge window James would be OK with
Joe's fix for the warning by then.  Perhaps I was wrong.

If under my control, I would never _ever_ let something like that
linger for weeks upon weeks in my tree.  24 hour resolution, tops.

And the same goes for Joe Perches, which is why I trust him and merged
his changes which triggered the warning in the first place.  I can
always count on him to do something immediately to try and fix
fallout, or in the worst case say "ok we can't resolve this just
revert my original change".

So I'm sorry, I'll never create a situation again where the SCSI
maintainer is in the critical path for getting a warning fixed. :-)
