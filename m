From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULLv2] vhost: cleanups and fixes
Date: Thu, 2 May 2013 13:26:41 -0700
Message-ID: <CA+55aFyzq+EBHiKYyEw3OXWKeeTbwt1sCYACfD4YsOWCBBZTVQ@mail.gmail.com>
References: <20130502201106.GA17385@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: KVM list <kvm@vger.kernel.org>, virtualization@lists.osdl.org,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Asias He <asias@redhat.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f51.google.com ([209.85.212.51]:62204 "EHLO
	mail-vb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758644Ab3EBU0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 16:26:42 -0400
In-Reply-To: <20130502201106.GA17385@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 2, 2013 at 1:11 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Hi Linus,
> This is exactly same code as my previous pull sent earlier, the diffstat
> was wrong however, I did a merge with master which fixed that.

See my other email. THIS IS NOT A VALID REASON TO DO A BACK-MERGE!

Extraneous merge commits that have no actual reason for development
are bad. They make it much harder to see what the actual development
thread was, because they mix up different branches. In fact, the whole
problem with the diffstat started with *another* extraneous merge, so
the "fix" was a result of a previous merge. This is exactly the kind
of reason why we want merges to be done by upstream developers, not
"back-merges" by downstream.

Now that merge is in your development tree, and if/when you start
doing development on top of that, the same kind of problem will
continue. Together with making it much harder to see in the history
what _your_ development stream was, because now it's no longer linear
and mixes in random points of the merge window.

Don't do this. Why do I have to write one of these "DON'T DO
BACK-MERGES" every single merge window? I really wish people listened,
instead of every single developer deciding that "it's ok if _I_ do it,
I'm sure Linus is complaining about all those *other* morons out
there".

When I say "don't do back-merges", I mean *you*. Yes, you. Not
somebody else. You.

                  Linus
