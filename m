From: "Kris Katterjohn" <kjak@ispwest.com>
Subject: Re: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Wed, 2 Nov 2005 22:54:07 -0800
Message-ID: <b70651b792f248ac8a5ca985a83e875f.kjak@ispwest.com>
Reply-To: "Kris Katterjohn" <kjak@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, jschlst@samba.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751168AbVKCGyN@vger.kernel.org>
To: "Mitchell Blank Jr" <mitch@sfgoth.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > From: Mitchell Blank Jr
> > > > (I trimmed the cc: list a bit; no need for this to be on LKML in my opinion)
> 
> I see you just added it back.  Oh well.

When I emailed (CC:) Herbert Xu (who emailed about this earlier), I got an email
back that said it couldn't send to him. So, I just added linux-kernel back so
he'd see it if he's interested at all.

> > > So I guess use my patch and take "inline" off? What do you think?
> 
> Well the original author presumably thought that the fast-path of
> load_pointer() was critical enough to keep inline (since it can be run many
> times per packet)  So they made the deliberate choice of separating it
> into two functions - one inline, one non-inline.
> 
> So my personal feeling is that the code is probably fine as it stands today.

It probably is. Doesn't really matter I guess.
 
> > Maybe "static" should be removed, too? Oh well.
> 
> Uh, why?  It's clearly a file-local function.

No real reason, just that none of the other functions in filter.c are static.


Thanks
