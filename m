From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: atl1: use magic packet wake-on-lan only
Date: Tue, 11 Nov 2008 18:35:46 -0600
Message-ID: <20081111183546.72de1714@osprey.hogchain.net>
References: <20081109150530.3eb555f9@osprey.hogchain.net>
	<49188091.3090709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Jie.yang@atheros.com, netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f11.google.com ([209.85.217.11]:37376 "EHLO
	mail-gx0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125AbYKLAg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 19:36:29 -0500
Received: by gxk4 with SMTP id 4so3053708gxk.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:36:28 -0800 (PST)
In-Reply-To: <49188091.3090709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Nov 2008 13:42:25 -0500
Chris Snook <csnook@redhat.com> wrote:

> J. K. Cliburn wrote:
> > atl1: use magic packet wake-on-lan only
> > 
> > Of the various WOL options provided in include/linux/ethtool.h, the
> > L1 NIC supports only magic packet.  Remove all options except magic
> > packet from the atl1 driver.
> 
> Technically, we could implement the rest via the programmable 
> pattern-matching hardware, but that would be an immense amount of
> work.

Thanks for the pointer to the pattern matching capability.  I had
forgotten about it.

What prompted the patch was a user asking some questions off-list about
the L1 and WOL, and I realized the atl1 driver was advertising WOL
options that weren't implemented.

I think the magic-packet-only patch I submitted to Jeff is still
relevant, but I'm going to explore the pattern matching capability and
see if we can implement some additional WOL options.  IMHO, though,
those should be provided in a separate (future) patch.  Do you agree?

Jay
