From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix routing tables with id > 255 for legacy software
Date: Tue, 10 Jun 2008 15:45:12 -0700 (PDT)
Message-ID: <20080610.154512.217403438.davem@davemloft.net>
References: <Pine.LNX.4.64.0806032036070.3438@bizon.gios.gov.pl>
	<4845A963.2050208@trash.net>
	<4845D26C.1030005@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl, jarkao2@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36861
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752102AbYFJWpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:45:17 -0400
In-Reply-To: <4845D26C.1030005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 04 Jun 2008 01:23:24 +0200

> Patrick McHardy wrote:
> > Krzysztof Oledzki wrote:
> >>
> >>> I'm neither opposed (as long as we don't add CONFIG options for
> >>> this) nor in favour - people using fixed applications won't notice,
> >>> and for other people it substitutes undesired behaviour by more
> >>> predictable undesirable behaviour,
> >>
> >> Exactly,
> >>
> >>> which is at least no loss :)
> >>
> >> OK, so I assume it is a very weak ack-by? ;)
> > 
> > Its a Not-NACKed-by: Patrick McHardy <kaber@trash.net> :)
> 
> 
> I'll upgrade that to a full ACK - the predictability allows
> to use the new features in combination with legacy apps and
> avoid any trouble if done carefully. There is some small risk
> of new breakage, but things probably won't work as expected
> anyway.

Patch applied with a typo fix in the changelog, it mentioned
that the new value was 253 when actually it is 252 :-)

Thanks!
