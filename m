From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 RFC 7/7] Modify tag_ksz.c so that tail tag code can be
 used by other KSZ switch drivers
Date: Sat, 14 Oct 2017 22:15:11 +0200
Message-ID: <20171014201511.GB24477@lunn.ch>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2017 at 01:33:05PM -0700, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Modify tag_ksz.c so that tail tag code can be used by other KSZ switch
> drivers.

There is multiple things going on in this patch. Please split the
special_mult_addr change into a separate patch, with an explanation
why it is needed. Same for the PTP indication.

It is always better to have lots of small patches, one logical change
per patch.

    Andrew
