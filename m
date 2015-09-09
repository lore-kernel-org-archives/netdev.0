From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v6 02/10] ss: created formatters for json and hr
Date: Wed, 9 Sep 2015 15:34:40 -0700
Message-ID: <20150909153440.49757e14@urahara>
References: <1441827801-9617-1-git-send-email-matthias.tafelmeier@gmx.net>
	<4b7ff1016053461a80465ce8138e12a2@HQ1WP-EXMB11.corp.brocade.com>
	<20150909143049.0aa08d37@urahara>
	<cf829f8ac6ea466eb9bb693350dd3291@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33546 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbbIIWea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 18:34:30 -0400
Received: by pacex6 with SMTP id ex6so22630620pac.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 15:34:29 -0700 (PDT)
In-Reply-To: <cf829f8ac6ea466eb9bb693350dd3291@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2015 22:00:36 +0000
Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:

> >> +#define STATIC_ASSERT(COND, MSG)			\
> >> +{							\
> >> +	char STATIC_ASSERT##MSG[(COND) ? 1 : -1];	\
> >> +	(void)STATIC_ASSERT##MSG[0];		\
> >> +}
> > 
> > If you are going to introduce this, please use same convention
> > as Linux kernel. ie. BUILD_BUG_ON()
> > 
> > Your code looks like it came out of some other project.
> > 
> 
> Well, but when using "BUILD_BUG_ON()" I would have to give up on having
> put out the MSG by compiler when a static issue occurs. I liked that notion.

If it won't compile, people will look at the code. The message is really
irrelevant.
