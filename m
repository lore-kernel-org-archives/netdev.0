From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] mv88e6xxx: Fix mv88e6xxx_g1_irq_free() interrupt count
Date: Sun, 27 Nov 2016 22:39:12 +0100
Message-ID: <20161127213912.GG13318@lunn.ch>
References: <1480279424-7830-1-git-send-email-afaerber@suse.de>
 <20161127212256.GC13318@lunn.ch>
 <ff0d121a-0ecb-8af7-af11-cf94df31639c@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58799 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752700AbcK0VjS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 16:39:18 -0500
Content-Disposition: inline
In-Reply-To: <ff0d121a-0ecb-8af7-af11-cf94df31639c@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 10:32:41PM +0100, Andreas Färber wrote:
> Hi Andrew,
> 
> Am 27.11.2016 um 22:22 schrieb Andrew Lunn:
> > On Sun, Nov 27, 2016 at 09:43:44PM +0100, Andreas Färber wrote:
> >> mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
> >> so free the same amount. This will be 8 or 9 in practice, less than 16.
> > 
> > Hi Andreas
> > 
> > The patch is correct, but please read
> > Documentation/networking/netdev-FAQ.txt
> > and then resubmit the patch.
> 
> Do you mean --subject-prefix="PATCH net-next"

Yep.

Thanks
	Andrew
