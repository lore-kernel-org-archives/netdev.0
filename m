From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 poweroff screws up my network
Date: Wed, 19 May 2010 08:14:40 -0700
Message-ID: <20100519081440.2883e71d@nehalam>
References: <20100519143208.GL3900@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle McMartin <kmcmartin@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59096 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830Ab0ESPPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 11:15:18 -0400
In-Reply-To: <20100519143208.GL3900@ihatethathostname.lab.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 May 2010 10:32:08 -0400
Kyle McMartin <kmcmartin@redhat.com> wrote:

> Hi Stephen,
> 
> I've noticed a rather strange problem with the onboard sky2 on one of my
> machines. When I halt -p it, my router stops passing traffic completely
> until I kill the power to the machine entirely. If it's just been shut
> down with halt -p, it recovers immediately after turning it back on,
> while it's in BIOS.
> 
> Any thoughts on this? My guess is its because the sky2 shutdown puts the
> nic to sleep and when the host is off, bad things happen.
> 
> regards, Kyle

The sky2 shutdown puts the chip in Wake On Lan state; this
does a separate link speed negotiation (100 mbit) which may be a problem
if speed duplex is forced.
