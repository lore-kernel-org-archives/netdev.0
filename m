From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 15:22:47 -0700
Message-ID: <1428445367.25985.214.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
	 <20150407.155209.47396464487922345.davem@davemloft.net>
	 <20150407210248.GC24631@electric-eye.fr.zoreil.com>
	 <20150407.172748.700634713750750146.davem@davemloft.net>
	 <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5524564C.9090809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35746 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbDGWWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:22:50 -0400
Received: by iggg4 with SMTP id g4so25226334igg.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 15:22:48 -0700 (PDT)
In-Reply-To: <5524564C.9090809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 15:12 -0700, Alexander Duyck wrote:
> On 04/07/2015 02:54 PM, Eric Dumazet wrote:

> > To be fair, only 2 drivers currently use dma_wmb()
> 
> Hey, I got at least 4..  :-)  I only got around to patching 3 Intel 
> drivers and one RealTek since that is what I had to test with.  I was 
> honestly hoping there would be more interest from other developers to 
> pick this up and update their drivers to avoid unnecessary barriers but 
> it doesn't look like I have had much luck on that front.

Strange I see only 2 drivers here, and no Intel ones :

# git grep -l dma_wmb drivers/net
drivers/net/ethernet/amd/xgbe/xgbe-dev.c
drivers/net/ethernet/realtek/r8169.c

I probably missed something ;)
