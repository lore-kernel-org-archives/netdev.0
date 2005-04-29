From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Question about QOS
Date: Fri, 29 Apr 2005 14:39:08 +0200
Message-ID: <20050429123908.GB577@postel.suug.ch>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch> <426E56DC.7000108@6wind.com> <20050426191454.GU577@postel.suug.ch> <426F42F0.9020609@6wind.com> <20050427114216.GV577@postel.suug.ch> <427225B2.6010705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas DICHTEL <nicolas.dichtel@6wind.com>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427225B2.6010705@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <427225B2.6010705@trash.net> 2005-04-29 14:16
> Why abs(delta)? It could be above bound, in fact all cases besides
> delta_sec > 2 doesn't take care to stay inside [0..bound] at all.

Doh, of course. Absolutely correct.
