From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 20 Aug 2009 21:42:30 +0200
Message-ID: <200908202142.30264.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <200908192307.22112.rene.mayrhofer@gibraltar.at> <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:38076 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbZHTTmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 15:42:37 -0400
In-Reply-To: <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 20. August 2009 00:05:03 schrieb Mike McCormack:
> 2009/8/20 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> > Pulling the latest sky2.c and sky2.h from net-next-2.6 and applying the
> > patch rids me of the oops - it is unreproducible right now. However, a
> > networking restart (i.e. all interfaces attached to sky2) leaves the
> > devices in a state where they no longer receive any network packets (at
> > least nothing visible in tcpdump). In this state, rmmod sky2 / modprobe
> > sky2 gives:
>
> After you've got it into that state, does "rmmod sky2; modprobe sky2"
> change anything?

Nope, tried that multiple times...

Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/
