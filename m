From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 13:52:44 -0700
Message-ID: <1331758364.6022.66.camel@edumazet-glaptop>
References: <20120314190156.622c8cd5@vostro>
	 <1331745314.6022.27.camel@edumazet-glaptop>
	 <20120314192945.65867e9f@vostro>
	 <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120314215142.655ae607@vostro>
	 <1331755965.6022.55.camel@edumazet-glaptop>
	 <20120314223343.23dc9df3@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:40438 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757489Ab2CNUwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:52:47 -0400
Received: by dadp12 with SMTP id p12so3499591dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 13:52:47 -0700 (PDT)
In-Reply-To: <20120314223343.23dc9df3@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 22:33 +0200, Timo Teras wrote:

> # ethtool -S eth2
> NIC statistics:
>      tx_packets: 2069391193
>      rx_packets: 3245815642
>      tx_errors: 0
>      rx_errors: 645238
>      rx_missed: 31414

So many packets on your tests, did you fresh reboot your machine before
doing them ?

Is your cpu fully loaded when doing your wget ?
