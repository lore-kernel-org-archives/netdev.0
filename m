From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 01/16] dt-bindings: net: update Marvell PPv2
 binding for PPv2.2 support
Date: Thu, 2 Feb 2017 17:44:57 +0100
Message-ID: <20170202174457.17ceabe9@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943592-12556-2-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170107093228.GI14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Pawel Moll <pawel.moll@arm.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Rob Herring <robh+dt@kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Kumar Gala <galak@codeaurora.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56943 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdBBQpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:45:00 -0500
In-Reply-To: <20170107093228.GI14217@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sat, 7 Jan 2017 09:32:28 +0000, Russell King - ARM Linux wrote:
> On Wed, Dec 28, 2016 at 05:46:17PM +0100, Thomas Petazzoni wrote:
> > @@ -31,7 +43,7 @@ Optional properties (port):
> >    then fixed link is assumed, and the 'fixed-link' property is
> >    mandatory.  
> 
> Not directly related to this patch, but this context is wrong.  The
> PP2 driver _requires_ a PHY.  It doesn't support fixed-link in its
> current form.  I think the DT binding describes an expectation of
> a future driver.
> 
> The side effect is that if trying to use a fixed-link on any port,
> the ethernet driver fails to probe.

Correct. I will send a patch to adjust the Device Tree binding
documentation accordingly. Thanks for noticing this mistake!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
