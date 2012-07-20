From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16]: Kill the ipv4 routing cache.
Date: Fri, 20 Jul 2012 18:43:54 +0200
Message-ID: <1342802634.2626.7718.camel@edumazet-glaptop>
References: <20120719.143403.1702333347618917729.davem@davemloft.net>
	 <1342796969.2678.12.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120720.092614.1285553995467252576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58371 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2GTQoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:44:03 -0400
Received: by bkwj10 with SMTP id j10so3592243bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 09:44:02 -0700 (PDT)
In-Reply-To: <20120720.092614.1285553995467252576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 09:26 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 20 Jul 2012 16:09:29 +0100
> 
> > On Thu, 2012-07-19 at 14:34 -0700, David Miller wrote:
> >> The ipv4 routing cache is non-deterministic, performance wise, and is
> >> subject to reasonably easy to launch denial of service attacks.
> > [...]
> > 
> > This is a great explanation, but it still doesn't appear to be going
> > into the commit log...
> 
> What in the world do you mean?
> 
> When I actually commit this stuff, I'll have it all in a branch and
> merge it into net-next's master using "git merge --no-ff" and then use
> the merge commit to add this commit message test.

I am not familiar with this "git merge --no-ff", so the following
might be completely irrelevant :

It would be nice if you can copy the changelog of 00/16 to 01/16

01/16 has no changelog, and it probably can confuse git users in the
future, since this patch is not trivial.
