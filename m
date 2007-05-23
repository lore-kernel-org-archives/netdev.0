From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] Fix incorrect prototype for ipxrtr_route_packet()
Date: Wed, 23 May 2007 19:25:01 +0200
Message-ID: <200705231925.02591.netdev@axxeo.de>
References: <1179398893.2859.479.camel@shinybook.infradead.org> <1179452912.2859.521.camel@shinybook.infradead.org> <20070517.200357.112621854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:60485 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773AbXEWRZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 13:25:25 -0400
In-Reply-To: <20070517.200357.112621854.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller schrieb:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Fri, 18 May 2007 09:48:32 +0800
> > On Thu, 2007-05-17 at 15:27 -0700, Andrew Morton wrote:
> > > If only we could find some way in which all callers of a function as
> > > well as its definition can see the same declaration? 
> > 
> > Well, building with --combine helps. :)

> I think it might be useful to be able to optionally to a --combine
> build on the whole tree with like allyeconfig or something crazy like
> that.  Just as a once-in-a-while thing to catch declaration mismatch
> and other similar issues.

I would LOVE to see a config option or build target for that. At the moment
I haven't figured out, how to do this correctly with Kbuild.

Regards

Ingo Oeser
