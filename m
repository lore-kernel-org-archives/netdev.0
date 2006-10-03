From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 21:13:51 +0200
Message-ID: <20061003191350.GP14180@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net> <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain> <20060922183812.GF4161@dezo.moloch.sk> <20060922115008.5060c599@localhost.localdomain> <20061003182119.GM14180@dezo.moloch.sk> <20061003113538.4c3fe57d@freekitty> <20061003183948.GO14180@dezo.moloch.sk> <20061003120355.0730097a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:55002 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S1030487AbWJCTNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 15:13:53 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061003120355.0730097a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> > > What speed and duplex are you using?
> > 
> > 1000 Mbps, full duplex
> > 
> > > What MTU are you using.
> > 
> > 1500
> 
> Are you sure? I assume you are using the latest driver from Linus's
> git repository. That version adds support for fragmented receive, but
> that code shouldn't be doing anything unless MTU > page size (4K).

Absolutely positive on the MTU and speed/duplex.

!!!
As for the driver version, I'm using the one in the stock 2.6.18 kernel,
NOT the one in Linus' git.
!!!

If I should be using a newer version, please send me a patch, or tell me
a way to obtain one from the git repository that doesn't involve syncing
the whole repository (not enough intl bandwith for that sort of thing
here).

-mato
