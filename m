From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH] mv88e6xxx: Fix mv88e6xxx_g1_irq_free() interrupt count
Date: Sun, 27 Nov 2016 22:32:41 +0100
Message-ID: <ff0d121a-0ecb-8af7-af11-cf94df31639c@suse.de>
References: <1480279424-7830-1-git-send-email-afaerber@suse.de>
 <20161127212256.GC13318@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55365 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752723AbcK0Vco (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 16:32:44 -0500
In-Reply-To: <20161127212256.GC13318@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Am 27.11.2016 um 22:22 schrieb Andrew Lunn:
> On Sun, Nov 27, 2016 at 09:43:44PM +0100, Andreas Färber wrote:
>> mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
>> so free the same amount. This will be 8 or 9 in practice, less than 16.
> 
> Hi Andreas
> 
> The patch is correct, but please read
> Documentation/networking/netdev-FAQ.txt
> and then resubmit the patch.

Do you mean --subject-prefix="PATCH net-next" or something else?

Thanks,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
