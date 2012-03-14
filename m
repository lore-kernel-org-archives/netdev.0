From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 13:12:45 -0700
Message-ID: <1331755965.6022.55.camel@edumazet-glaptop>
References: <20120314190156.622c8cd5@vostro>
	 <1331745314.6022.27.camel@edumazet-glaptop>
	 <20120314192945.65867e9f@vostro>
	 <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120314215142.655ae607@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:48328 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030518Ab2CNUMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:12:48 -0400
Received: by gghe5 with SMTP id e5so2245070ggh.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 13:12:48 -0700 (PDT)
In-Reply-To: <20120314215142.655ae607@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 21:51 +0200, Timo Teras wrote:

> Very good point. I thought gso also enabled gro, but seems that my
> ethtool was old.
> 
> And GRO was enabled along with some other stuff. Turning GRO off made
> my tcp performance immediately a lot better; jumped from 2MB/s to 8MB/s
> or so (not ideal yet, though; but the remainder of the difference could
> be related to other issue).
> 
> So something is definitely broke in 3.0.x with GRO enabled, but GSO off.

"ifconfig eth2 ; netstat -s" can really help, I suspect tcp stack drops
