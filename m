From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Wed, 2 Nov 2005 22:58:09 -0800
Message-ID: <20051103065809.GC27232@gaz.sfgoth.com>
References: <5b1bc8f2a7f34523b323fc1b58ef4c26.kjak@ispwest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jschlst@samba.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751171AbVKCGoW@vger.kernel.org>
To: Kris Katterjohn <kjak@users.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <5b1bc8f2a7f34523b323fc1b58ef4c26.kjak@ispwest.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kris Katterjohn wrote:
> > From: Mitchell Blank Jr
> > > (I trimmed the cc: list a bit; no need for this to be on LKML in my opinion)

I see you just added it back.  Oh well.

> > So I guess use my patch and take "inline" off? What do you think?

Well the original author presumably thought that the fast-path of
load_pointer() was critical enough to keep inline (since it can be run many
times per packet)  So they made the deliberate choice of separating it
into two functions - one inline, one non-inline.

So my personal feeling is that the code is probably fine as it stands today.

> Maybe "static" should be removed, too? Oh well.

Uh, why?  It's clearly a file-local function.

-Mitch
