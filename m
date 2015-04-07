From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 14:54:45 -0700
Message-ID: <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
	 <20150407.155209.47396464487922345.davem@davemloft.net>
	 <20150407210248.GC24631@electric-eye.fr.zoreil.com>
	 <20150407.172748.700634713750750146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, nix@esperi.org.uk,
	rl@hellgate.ch, gurligebis@gentoo.org, alexander.h.duyck@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33371 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbDGVyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:54:47 -0400
Received: by iebmp1 with SMTP id mp1so59358966ieb.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 14:54:47 -0700 (PDT)
In-Reply-To: <20150407.172748.700634713750750146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 17:27 -0400, David Miller wrote:

> That's exactly dma_wmb().
> 
> It barriers cpu writes so that the device sees things in a certain
> order.
> 
> It's what all the most common ethernet chip drivers use in their
> descriptor handling routines now.

To be fair, only 2 drivers currently use dma_wmb()
