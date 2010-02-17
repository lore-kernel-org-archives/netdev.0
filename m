From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/41] CAPI: Major rework, tons of bug fixes
Date: Tue, 16 Feb 2010 16:02:01 -0800 (PST)
Message-ID: <20100216.160201.62198315.davem@davemloft.net>
References: <cover.1265659933.git.jan.kiszka@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, marcel@holtmann.org
To: jan.kiszka@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932771Ab0BQABq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 19:01:46 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Kiszka <jan.kiszka@web.de>
Date: Mon,  8 Feb 2010 21:12:04 +0100

> Here is the second take of my CAPI rework. I tried to address all
> feedback on v1, so this one comes with the following changes:
> 
>  o rebased over net-next
>  o reworked locking of the NCCI TTY using latest and greatest tty_port
>    features and kref, hopefully in the right way
>  o more fine-grained patch steps for the tricky TTY rework
>  o dynamic major for NCCI TTYs, ie. CAPI no longer claims 191
>  o dynamic TTY minor registrations, completely obsoleting capifs
>  o schedule capifs for removal
>  o some small additional cleanups
> 
> I kept my capifs fixes though this thing should die in the future. The
> work is done, and people may still use it due to their distro
> configuration (and the hard-wired loading by capiinit - needs fixing).

Thank you for all of your hard work.

I've applied your entire series to net-next-2.6

Thanks again!
