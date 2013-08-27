From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/5] netfilter: SYNPROXY target v3
Date: Tue, 27 Aug 2013 11:05:24 +0200
Message-ID: <20130827090523.GB9805@macbook.localnet>
References: <1377586216-7024-1-git-send-email-kaber@trash.net>
 <Pine.LNX.4.64.1308270951520.25216@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1308270951520.25216@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 27, 2013 at 10:35:56AM +0200, Jesper Dangaard Brouer wrote:
> On Tue, 27 Aug 2013, Patrick McHardy wrote:
> 
> >Since the SYN proxy can't know the options the server supports, they have
> >to be specified as parameters to the SYNPROXY target. The assumption is that
> >these options are constant as long as you don't change settings on the
> >server.
> 
> Future extention idea: Perhaps we could auto detect the options the
> server supports, after the first connection have been created?
> I know this is problematic/difficult for the iptables framework,
> because it would require the module to keep an internal dynamic
> state, which iptables module does not handle well (due to how the
> entires ruleset is reloaded on rule changes).

The main reason why I didn't add this is since it assumes you have a
single rule per destination. That assumption can't be made, so you'd
have to maintain a table of options per destination.

I'll add the synconf tool to generate rules based on what the server
actually supports to the iptables repository once this has been merged.

> Guess, the easiest thing to implement, would be to give a warning,
> if the options (the server supports) does not match the modules config.

Yes, that could be done.
