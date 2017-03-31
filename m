From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Fri, 31 Mar 2017 23:56:52 +0200
Message-ID: <20170331215652.GA27307@lunn.ch>
References: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
 <1490821714.3177.189.camel@kernel.crashing.org>
 <1490834778.3177.197.camel@kernel.crashing.org>
 <20170329.201517.300684629549047939.davem@davemloft.net>
 <1490954367.3177.236.camel@kernel.crashing.org>
 <20170331135207.GG22609@lunn.ch>
 <1490994867.3177.241.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42436 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755459AbdCaV46 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 17:56:58 -0400
Content-Disposition: inline
In-Reply-To: <1490994867.3177.241.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> They are incremental, but some of them are trivial and in the end
> it's the end result that matters but yes I could probably split some
> misc stuff, rx path, tx path, and more misc.

Hi Ben

Trivial patches are good. They are easy to review. You should be
aiming for patches which are obviously correct, where ever possible.
Refactoring existing code often has a lot of obviously correct
patches, and a few complex patches which take some effort to review.

       Andrew
