From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 16:01:54 -0800
Message-ID: <AANLkTimXqZS4+1WgQcaAFG9CY2G-RPNy7UbXdjn8+_e4@mail.gmail.com>
References: <20110310.153444.115930379.davem@davemloft.net> <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46881 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754004Ab1CKACo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 19:02:44 -0500
In-Reply-To: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 3:49 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Now, I admit that it's a git usability bug: for normal "git commit",
> git will _force_ you to write a message, and sadly, for merges, I made
> it instead just do the message automatically. My bad. I designed it
> for the kind of merges I do, where the the automatic merge message
> actually tells you what the merge is all about.

Btw, the reason I got really upset this time (and I've let it slide
before), is that this time your back-merge not only had that totally
useless merge message (that's happened before), but *because* you did
that back-merge, it also ends up making _my_ merge message totally
useless - the one that normally contains good and useful information
(a valid source of merging, and the abbreviated shortlog of what was
merged).

Why? Because you had done the back-merge very recently, my pull
request then ends up being a fast-forward, so your _useless_ merge
message basically entirely replaces the one that would have been
useful.

Yes, I could do it with "git pull --no-ff", but I have to admit to
hating adding more artificial merges into the tree just to get the
merge information. I didn't think the "--no-ff" flag was a good idea,
and I've never used it so far, but I have to say that now I'm
wavering.

I probably also should just talk to Junio and tell him that the whole
"totally automatic merge messages" was another horrible design
mistake. But if we do fix that in git, I suspect it will (a) break
scripts that expected the automatic silent merge and (b) take a long
time to percolate to people. So it might be one of those "we have to
live with it due to backwards compatibility reasons". Ugh.

                                    Linus
