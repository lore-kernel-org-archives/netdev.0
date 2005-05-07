From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Sat, 7 May 2005 02:36:13 +0200
Message-ID: <20050507003613.GJ28419@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <20050506214437.GH28419@postel.suug.ch> <20050507.091744.106860599.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, pablo@eurodev.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050507.091744.106860599.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050507.091744.106860599.yoshfuji@linux-ipv6.org> 2005-05-07 09:17
> In article <20050506214437.GH28419@postel.suug.ch> (at Fri, 6 May 2005 23:44:37 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > Quite silly regular expression implementation for textsearch
> > infrastructure. Still has issues with textsearch_next() and
> > can probably be optimized a lot but should be a good base
> > to work on.
> 
> Would you add some reference(s) on algorithm etc.?

Comes out of my own mind which means it's probably pretty poor, it
simply takes a deterministic finite state machine and runs it on
the text.
