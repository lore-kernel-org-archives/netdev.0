From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Wed, 14 Mar 2012 21:53:19 +0100
Message-ID: <20120314205319.GA28394@electric-eye.fr.zoreil.com>
References: <20120314190156.622c8cd5@vostro> <1331745314.6022.27.camel@edumazet-glaptop> <20120314192945.65867e9f@vostro> <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com> <20120314215142.655ae607@vostro> <1331755965.6022.55.camel@edumazet-glaptop> <20120314223343.23dc9df3@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50378 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761455Ab2CNUyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 16:54:53 -0400
Content-Disposition: inline
In-Reply-To: <20120314223343.23dc9df3@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> # ethtool -S eth2
> NIC statistics:
>      tx_packets: 2069391193
>      rx_packets: 3245815642
>      tx_errors: 0
>      rx_errors: 645238
>      rx_missed: 31414

It does not look like stuff for the higher layers guys.

Can you tshark -w foobar on the sender side and
'while : ; do sleep 1; ethtool -S eth2 >> glop; done' on the receiver
during a bad wget (a big zero filled file should compress well).

-- 
Ueimor
