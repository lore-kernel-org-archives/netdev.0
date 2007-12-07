From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net/xfrm/xfrm_policy.c: Some small improvements
Date: Thu, 06 Dec 2007 19:22:49 -0800 (PST)
Message-ID: <20071206.192249.193354742.davem@davemloft.net>
References: <20071206110123.GB2469@hacking>
	<20071206.031434.179419183.davem@davemloft.net>
	<4758093A.7010608@student.ltu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, akpm@osdl.org, netdev@vger.kernel.org
To: ricknu-0@student.ltu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755260AbXLGDXH@vger.kernel.org>
In-Reply-To: <4758093A.7010608@student.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Knutsson <ricknu-0@student.ltu.se>
Date: Thu, 06 Dec 2007 15:37:46 +0100

> David Miller wrote:
> > But this time I'll just let you know up front that I
> > don't see much value in this patch.  It is not a clear
> > improvement to replace int's with bool's in my mind and
> > the other changes are just whitespace changes.
> >   
> Is it not an improvement to distinct booleans from actual values? Do you 
> use integers for ASCII characters too? It can also avoid some potential 
> bugs like the 'if (i == TRUE)'...
> What is wrong with 'size_t' (since it is unsigned, compared to (some) 
> 'int')?

When you say "int found;" is there any doubt in your mind that
this integer is going to hold a 1 or a 0 depending upon whether
we "found" something?

That's the problem I have with these kinds of patches, they do
not increase clarity, it's just pure mindless edits.

In new code, fine, use booleans if you want.

I would even accept that it helps to change to boolean for
arguments to functions that are global in scope.

But not for function local variables in cases like this.
