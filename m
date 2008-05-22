From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NETLINK]: Fix nla_parse_nested_compat() to call nla_parse()
 directly
Date: Thu, 22 May 2008 11:02:58 -0700
Message-ID: <20080522110258.4cd23801@extreme>
References: <20080522002155.GP20815@postel.suug.ch>
	<20080522113720.GR20815@postel.suug.ch>
	<48356AE3.7050700@trash.net>
	<20080522.104913.231161238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48421 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756074AbYEVSC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:02:59 -0400
In-Reply-To: <20080522.104913.231161238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2008 10:49:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 22 May 2008 14:45:23 +0200
> 
> > Thomas Graf wrote:
> > > The purpose of nla_parse_nested_compat() is to parse attributes
> > > which contain a struct followed by a stream of nested attributes.
> > > So far, it called nla_parse_nested() to parse the stream of
> > > nested attributes which was wrong, as nla_parse_nested() expects
> > > a container attribute as data which holds the attribute stream.
> > > It needs to call nla_parse() directly while pointing at the
> > > next possible alignment point after the struct in the beginning
> > > of the attribute.
> > >
> > > With this patch, I can no longer reproduce the reported leftover
> > > warnings.
> > >
> > > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > Looks good to me, thanks for fixing this Thomas.
> 
> Patch applied, thanks everyone.

Pls, push this to stable as well.
