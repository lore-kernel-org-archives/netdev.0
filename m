From: Junio C Hamano <gitster@pobox.com>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 16:29:25 -0800
Message-ID: <7vvczpdvve.fsf@alter.siamese.dyndns.org>
References: <20110310.153444.115930379.davem@davemloft.net>
 <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
 (Linus Torvalds's message of "Thu, 10 Mar 2011 15:49:40 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Thu, Mar 10, 2011 at 3:34 PM, David Miller <davem@davemloft.net> wrote:
>> ...
> Look at that commit message:
>
>     Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
>
> That is literally the WHOLE message. Ask yourself: is that commit
> doing anything useful? Does the commit message explain what it is
> doing, and why you are doing it?
> ...
> Now, I admit that it's a git usability bug: for normal "git commit",
> git will _force_ you to write a message, and sadly, for merges, I made
> it instead just do the message automatically. My bad. I designed it
> for the kind of merges I do, where the the automatic merge message
> actually tells you what the merge is all about. But for back-merges,
> the automatic message is totally worthless, and it is DOUBLY worthless
> when you do it the way you do it, namely from some local directory of
> your own.

I admit that I back-merged a few times my own master to a largish topic
branch, when updates that happened on the master front since the topic
forked from it helped to clean up the topic.  When I did so, I knew better
to say "git commit --amend" to reword the merge message to say something
like:

	Merge 'master' to 'jc/frotz' for xyzzy feature

so it wasn't a huge problem for me personally to keep the history useful,
but I agree that it would be better to make it harder for mortals to just
backmerge without doing the rewording.

The question is how.  Perhaps when the merge is made from the default
upstream, i.e. with "git pull" (no parameters) or "git merge @{u}", we
should automatically give the user an editor?
