From: Bram <bram@linux.kernel.as.avontuur.org>
Subject: Re: Possible bug in realtek 8169 ethernet driver
Date: Tue, 7 Aug 2007 14:45:35 +0200
Message-ID: <20070807124535.GO2761__17238.1692020737$1186492493$gmane$org@avontuur.org>
References: <20070805155915.GM2761@avontuur.org> <20070805213557.GA21500@electric-eye.fr.zoreil.com> <20070806133752.GN2761@avontuur.org> <20070806210637.GA18611@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bram.avontuur.org ([84.244.182.76]:51234 "EHLO
	bram.avontuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759460AbXHGMph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 08:45:37 -0400
Content-Disposition: inline
In-Reply-To: <20070806210637.GA18611@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Bram <bram@linux.kernel.as.avontuur.org> :
> [...]
> > The device now works! But, it still comes up as eth2 instead of eth0,
> > even though it's first detected as eth0. There are no other network
> 
> Check the udev rules and/or your init scripts ?
> 
You're right, it's a udev script assigning new names to unknown cards, I
wasn't aware of that.

Thanks,
Bram
