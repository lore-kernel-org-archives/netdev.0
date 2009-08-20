From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 19 Aug 2009 17:46:29 -0700
Message-ID: <20090819174629.649f837f@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
	<200908190902.02854.rene.mayrhofer@gibraltar.at>
	<392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
	<200908192307.22112.rene.mayrhofer@gibraltar.at>
	<392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54735 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753420AbZHTAr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 20:47:28 -0400
In-Reply-To: <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2009 07:05:03 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 2009/8/20 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> 
> > Pulling the latest sky2.c and sky2.h from net-next-2.6 and applying the patch
> > rids me of the oops - it is unreproducible right now. However, a networking
> > restart (i.e. all interfaces attached to sky2) leaves the devices in a state
> > where they no longer receive any network packets (at least nothing visible in
> > tcpdump). In this state, rmmod sky2 / modprobe sky2 gives:
> 
> After you've got it into that state, does "rmmod sky2; modprobe sky2"
> change anything?
> 
> thanks,
> 
> Mike

Please send (I forget) the hardware info (lspci) and the register values
from ethtool -d ethX.

Some part of the power control doesn't work on Rene's system, so
device falls off the bus. Probably no auxilary +5 supplied, the register
values will tell whether driver is at fault (turning on aux when not
available), or hardware is lying about vaux.
