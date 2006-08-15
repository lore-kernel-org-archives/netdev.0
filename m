From: Chris Lightfoot <chris@ex-parrot.com>
Subject: Re: Fw: crash in ipt_do_table
Date: Tue, 15 Aug 2006 15:29:18 +0100
Message-ID: <3SmNv/haNWRU.dTuwTfL4X/51VCkr8nnANQ@sphinx.mythic-beasts.com>
References: <20060815005422.0c47bddb.akpm@osdl.org> <44E1D3A2.3020604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wumpus.mythic-beasts.com ([212.69.37.9]:65168 "EHLO
	wumpus.mythic-beasts.com") by vger.kernel.org with ESMTP
	id S1030304AbWHOO3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 10:29:21 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44E1D3A2.3020604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 04:01:06PM +0200, Patrick McHardy wrote:
> Andrew Morton wrote:
> > From: Chris Lightfoot <chris@ex-parrot.com>
> >
> > EIP is at ipt_do_table+0xa9/0x2fc [ip_tables]
> >
> > This has only happened once so far, so I'm not (yet) aware
> > of any way to reproduce it. Unfortunately I don't have a
> > copy of the iptables rules themselves at the time of the
> > crash -- on that system they're created dynamically and
> > the specific setup doesn't survive a reboot.
> 
> Any chance you're also changing your ruleset dynamically? If yes
> this patch might help.

yes, we are. Thanks for the patch -- I will apply it and
see what happens.

-- 
``The fishy glitter in his eye became intensified. He looked like
  a halibut which had been asked by another halibut to lend it a
  couple of quid till next Wednesday.'' (P G Wodehouse)
