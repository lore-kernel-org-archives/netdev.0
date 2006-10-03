From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 12:16:24 -0700
Message-ID: <20061003121624.77a08cb5@freekitty>
References: <20060922112442.GB4161@dezo.moloch.sk>
	<20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
	<20060922182924.GE4161@dezo.moloch.sk>
	<20060922113152.02874cbc@localhost.localdomain>
	<20060922183812.GF4161@dezo.moloch.sk>
	<20060922115008.5060c599@localhost.localdomain>
	<20061003182119.GM14180@dezo.moloch.sk>
	<20061003113538.4c3fe57d@freekitty>
	<20061003183948.GO14180@dezo.moloch.sk>
	<20061003120355.0730097a@freekitty>
	<20061003191350.GP14180@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39339 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030486AbWJCTQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 15:16:30 -0400
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20061003191350.GP14180@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006 21:13:51 +0200
Martin Lucina <mato@kotelna.sk> wrote:

> shemminger@osdl.org said:
> > > > What speed and duplex are you using?
> > > 
> > > 1000 Mbps, full duplex
> > > 
> > > > What MTU are you using.
> > > 
> > > 1500
> > 
> > Are you sure? I assume you are using the latest driver from Linus's
> > git repository. That version adds support for fragmented receive, but
> > that code shouldn't be doing anything unless MTU > page size (4K).
> 
> Absolutely positive on the MTU and speed/duplex.
> 
> !!!
> As for the driver version, I'm using the one in the stock 2.6.18 kernel,
> NOT the one in Linus' git.
> !!!
> 
> If I should be using a newer version, please send me a patch, or tell me
> a way to obtain one from the git repository that doesn't involve syncing
> the whole repository (not enough intl bandwith for that sort of thing
> here).
> 
> -mato

If you are seeing truesize errors with the stock 2.6.18 kernel then
some other protocol is messing with the skb's?  Are you using IPV6?
Or PPPoE or something like that.

-- 
Stephen Hemminger <shemminger@osdl.org>
