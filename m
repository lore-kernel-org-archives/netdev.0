From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Fri, 11 Dec 2009 10:49:38 -0500
Message-ID: <4B226A12.5070102@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	<4B1F0151.10903@gmail.com> <20091208180801.88be28ba.akpm@linux-foundation.org> <4B20FC2E.7050809@gmail.com> <4B2102B4.7050702@gmail.com> <4B211452.40600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:34878 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334AbZLKPtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 10:49:35 -0500
Received: by ywh3 with SMTP id 3so962353ywh.22
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 07:49:41 -0800 (PST)
In-Reply-To: <4B211452.40600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> This is not necessary, David already _did_ the thing, and _told_ so.
> 
There doesn't seem to be a patch sent to the list, at least it didn't
show up in my mail, nor is it in the archive.  Such mistakes happen.


> You probably missed fact we are in merge window, so fixes (and only fixes)
> are pushed into net-2.6 tree.
> 
That's my understanding.  I'd asked a question earlier which tree to
patch against (which he didn't answer), but a later message was more
helpful and detailed.


> When Linus closes this merge window (issuing a linux-2.6.33-rc1 tag),
> then David re-opens net-next-2.6 tree for new stuff.
> 
That's my understanding, thanks again.  (This isn't new stuff.)


> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=3dc789320e1b310cb505dcd94512c279abcd5e1c
> 
Well, I'll be darned!  There must be some list that you're on that sends
out such notifications....

Not a good patch, as it accidentally removed the section comment.  And it
fails to describe or test against buffer overruns.

So, he'll have no problems backing out his patch and adding mine.
