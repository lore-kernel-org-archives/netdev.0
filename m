From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/5] [NET] Add skb_find_text() to search for a text pattern in skbs
Date: Sat, 28 May 2005 13:32:45 +0200
Message-ID: <20050528113245.GO15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch> <20050527224858.GK15391@postel.suug.ch> <4297E172.5020907@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <4297E172.5020907@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <4297E172.5020907@eurodev.net> 2005-05-28 05:11
> Still miss something here. You aren't looking for matches in skbs 
> inserted in skb_shinfo(skb)->frag_list. Have a look at rusty's skb_iter 
> functions. Since he cooked those for this purpose (string matching), why 
> don't we use them instead of yours ?

Absolutely, I'm planning to use rusty's skb_iter instead. I postponed
this to when the core infrastructure is stable but thanks a lot for
this comment.
