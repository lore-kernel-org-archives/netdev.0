From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] lan78xx: Remove trailing underscores from macros
Date: Tue, 06 Sep 2016 18:18:42 -0700
Message-ID: <1473211122.29864.1.camel@perches.com>
References: <cover.1473202982.git.joe@perches.com>
         <9235D6609DB808459E95D78E17F2E43D40910FF9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, UNGLinuxDriver@microchip.com,
        linux-kernel@vger.kernel.org
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0176.hostedemail.com ([216.40.44.176]:53068 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755132AbcIGBUE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 21:20:04 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40910FF9@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 23:19 +0000, Woojung.Huh@microchip.com wrote:
> > Joe Perches (2):
> >   lan78xx: Remove locally defined trailing underscores from defines and uses
> >   microchipphy.h and uses: Remove trailing underscores from defines and
> > uses
> > 
> >  drivers/net/phy/microchip.c  |    4 +-
> >  drivers/net/usb/lan78xx.c    |  368 +++++++--------
> >  drivers/net/usb/lan78xx.h    | 1068 +++++++++++++++++++++-----------------
> > ----
> >  include/linux/microchipphy.h |   72 +--
> >  4 files changed, 756 insertions(+), 756 deletions(-)
> 
> 
> Because there is no specific rule how to name defines, I'm not sure it is worth to change 1000+ lines.
> It may be better to set guideline for new submissions.
> 
> Welcome any comments.

Generally, more conforming to norms is better.
These FOO_ uses are non-conforming.

Is there anything other than a one-time cost
to apply these?  Is the same code used for
other platforms?
