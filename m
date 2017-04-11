From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Wed, 12 Apr 2017 08:06:41 +1000
Message-ID: <1491948401.7236.20.camel@kernel.crashing.org>
References: <20170411010436.23290-2-benh@kernel.crashing.org>
         <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
         <1491909225.4166.248.camel@kernel.crashing.org>
         <20170411.112733.1412982560568816717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51857 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753740AbdDKWJE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 18:09:04 -0400
In-Reply-To: <20170411.112733.1412982560568816717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 11:27 -0400, David Miller wrote:
> > I'll fix it in a next spin if Dave wants it that way but otherwise
> > I'm keen to leave it as it is.
> 
> Please fix this and respin.
> 
> Meanwhile get the coding style rules changed if you disagree with
> them.  A patch series review is not the place to argue about your
> disagreement with the coding style rules.

I will fix.

Note that I don't disagree with the rule as stated.

However I'd like to point out that the rule doesn't precisely match
the construct here as it's for a dangling single else while what I
had here is an else if ... so it's open to intepretation :-)

I also tend to disagree that coding style rules should be firm laws,
imho they should be considered in context and broken if they render
a given piece of code less clear.

That said, I will respin.

Cheers,
Ben.
