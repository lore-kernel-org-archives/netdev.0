From: "Changli Gao" <xiaosuo@gmail.com>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Thu, 30 Oct 2008 09:03:34 +0800
Message-ID: <412e6f7f0810291803j3858cd2fq373a9c4f49664825@mail.gmail.com>
References: <20081029102356.GA6165@ff.dom.local> <49083BF5.5090606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:42272 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534AbYJ3BDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 21:03:34 -0400
Received: by rv-out-0506.google.com with SMTP id k40so296178rvb.1
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 18:03:34 -0700 (PDT)
In-Reply-To: <49083BF5.5090606@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 6:33 PM, Patrick McHardy <kaber@trash.net> wrote:
> Only for purely informational purposes, for policing you'd want to
> use arrival rates. Since there are no users of estimators in the kernel
> besides policers (which use seperate ones), the point is not terribly
> important.

Where can I find sth. about this?

In fact, this bug is encountered when I am trying to implement a
statistic daemon in user space. It fetches the classes's statistics
data periodicity, then calculates the rate based on the data fetched.
In some cases, it reports the leaf classes's rate is over theirs
limit, but its ascent's isn't.

I think there must be someone does the same thing as me. So the
feature is important for them too. If we don't fix it, how can I
archive my requirement? Any comment?

-- 
Regards，
Changli Gao(xiaosuo@gmail.com)
