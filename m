From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] mac802154: fix typo in header guard
Date: Thu, 19 Mar 2015 14:58:36 +0100
Message-ID: <20150319135831.GA2024@omega>
References: <1426771420-29979-1-git-send-email-nicolas.iooss_linux@m4x.org>
 <20150319133724.GA14436@omega>
 <1426772786.23529.4.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, marcel@holtmann.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32906 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbCSN6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 09:58:43 -0400
Content-Disposition: inline
In-Reply-To: <1426772786.23529.4.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 02:46:26PM +0100, Paul Bolle wrote:
> On Thu, 2015-03-19 at 14:37 +0100, Alexander Aring wrote:
> > On Thu, Mar 19, 2015 at 09:23:40PM +0800, Nicolas Iooss wrote:
> > > Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
> > > Fixes: b6eea9ca354a ("mac802154: introduce driver-ops header")
> > 
> > Acked-by: Alexander Aring <alex.aring@gmail.com>
> > 
> > can you please queue this into bluetooth-next or even bluetooth?
> 
> Is the Fixes: tag needed?
> 
> mac802154.ko builds fine on my machine. There's also no error or warning
> included in the commit explanation. So it seems this is just a typo fix,
> not something that should be sent to stable too. Or did I miss something
> non-obvious?
> 

It's only an internal header which is used by c-files inside net/mac802154.
I am not sure the right handling of this kind of fix. That's why I said
to Marcel bluetooth-next or even bluetooth.

The header-guard working right now because the internal-header is included
only once in a c-file in "net/mac802154".

I currently imagine the following situation, when a stable patch comes in
and add a:

#include "driver-ops.h" 

in another internal header like "ieee802154_i.h" which is also part of
net/mac802154/ directory. Then the build will fail afterwards, but I
don't plan to send such patch to stable.

Nevertheless, then some build robots should notice about that. If nobody other
complains here, then I am fine to put this into bluetooth-next.

- Alex
