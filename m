From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Wed, 20 Aug 2008 19:47:52 +0200
Message-ID: <20080820174752.GB18419@torres.zugschlus.de>
References: <20080819172019.GA5823@torres.zugschlus.de> <20080819.132040.188336475.davem@davemloft.net> <1219166962.13090.12.camel@HP1> <20080819221439.GA19106@torres.zugschlus.de> <20080819223025.GA11221@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Haber <mh+linux-kernel@zugschlus.de>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.68.41]:55513 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbYHTRr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:47:56 -0400
Content-Disposition: inline
In-Reply-To: <20080819223025.GA11221@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 03:30:25PM -0700, Matt Carlson wrote:
> Can you try the attached patch?  The patch reduces the delay back to
> what it should have been.  If this helps, then it means you are being
> bitten by the same bug the upstream patch fixed.

It looks like the issue is fixed now. Thanks for your help.

Will this fix be in 2.6.26.3 and/or 2.6.27?

Now I need to understand why the other, nearly[1] identical box didn't
need the patch to function properly.

Greetings
Marc

[1] only difference is that the working box has two e1000 interfaces
on a PCI card in addition to the two tg3 interfaces on board (all four
of them being in use)

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
