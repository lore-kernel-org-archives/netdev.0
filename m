From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 8/8] ftgmac100: Document device-tree binding
Date: Thu, 13 Apr 2017 23:58:37 +1000
Message-ID: <1492091917.7236.104.camel@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
         <20170412224443.17906-9-benh@kernel.crashing.org>
         <20170413134250.GD16424@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33576 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753350AbdDMN7A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 09:59:00 -0400
In-Reply-To: <20170413134250.GD16424@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 15:42 +0200, Andrew Lunn wrote:
> > +- phy-mode: See ethernet.txt file in the same directory. If the
> > property is
> > +  absent, "rgmii" is assumed. Supported values are "rgmii" and
> > "rmii"
> 
> You might want to say rgmii*, or similar, it indicate the delayed
> versions are accepted as well.

You are right. I originally didn't accept them, then fixed that
up in the code but forgot to update the binding.

Dave, if that's the only issue, I'd rather send a separate later
tomorrow or so patch to amend the binding rather than send the whole
series all over again as this is rather a minor detail.

Cheers,
Ben.
