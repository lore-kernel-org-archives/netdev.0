From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Mon, 03 Apr 2017 16:46:10 +1000
Message-ID: <1491201970.26047.32.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-11-benh@kernel.crashing.org>
         <20170402184237.GB5189@lunn.ch>
         <1491168258.26047.18.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48813 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751214AbdDCGqW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 02:46:22 -0400
In-Reply-To: <1491168258.26047.18.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-03 at 07:24 +1000, Benjamin Herrenschmidt wrote:
> On Sun, 2017-04-02 at 20:42 +0200, Andrew Lunn wrote:
> 
> > Have you run lockdep tests on this?
> 
> Good idea. For some reason I run it regularly on powerpc but it never
> occurred to me to try it on that 800Mhz ARM11 :-)

That was the only thing lockdep spotted. I added the MDIO mutex to
the list as well, I'll sent the respun series later in case there's
more reviews coming.

Thanks !

Cheers,
Ben.
