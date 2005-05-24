From: David Lang <david.lang@digitalinsight.com>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Tue, 24 May 2005 00:55:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0505240051490.9001@qynat.qvtvafvgr.pbz>
References: <4292BA66.8070806@pobox.com> <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
 <4292C8EF.3090307@pobox.com> <Pine.LNX.4.58.0505232343260.2307@ppc970.osdl.org>
 <4292D7E1.80601@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261414AbVEXHzr@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4292D7E1.80601@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 May 2005, Jeff Garzik wrote:

> Linus Torvalds wrote:
>> 
>> On Tue, 24 May 2005, Jeff Garzik wrote:
>> 
>>> You are getting precisely the same thing you got under BitKeeper:  pull 
>>> from X, you get my tree, which was composed from $N repositories.  The 
>>> tree you pull was created by my running 'bk pull' locally $N times.
>> 
>> 
>> No. Under BK, you had DIFFERENT TREES.
>> 
>> What does that mean? They had DIFFERENT NAMES.
>> 
>> Which meant that the commit message was MEANINGFUL.
>
> Ok, I'll fix the commit message.
>
> As for different trees, I'm afraid you've written something that is _too 
> useful_ to be used in that manner.
>
> Git has brought with it a _major_ increase in my productivity because I can 
> now easily share ~50 branches with 50 different kernel hackers, without 
> spending all day running rsync.  Suddenly my kernel development is a whole 
> lot more _open_ to the world, with a single "./push".  And it's awesome.
>
> That wasn't possible before with BitKeeper, just due to sheer network 
> overhead of 50 trees.  With BitKeeper, the _only_ thing that kernel hackers 
> and users could get from me is a mush tree with everything merged into a big 
> 'ALL' repository.

couldn't you just have your multiple 'trees' use the same object 
repository directory (still a single group of files to push), but still 
have your trees with different names? it would be just a little more then 
the copy of the HEAD object (you'd have to change the name in it), but it 
should be easily scriptable)

or is there a limit in git that I'm overlooking that would prohibit this?

David Lang
