From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 19:29:14 +0000
Message-ID: <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120314190156.622c8cd5@vostro>
	 <1331745314.6022.27.camel@edumazet-glaptop>
	 <20120314192945.65867e9f@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42792 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753142Ab2CNT3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:29:17 -0400
In-Reply-To: <20120314192945.65867e9f@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 19:29 +0200, Timo Teras wrote:
[...]
> gro off. I am even trying now with:
> 
> Offload parameters for eth2:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
[...]

GRO isn't even reported there!  Apparently you need a newer version of
ethtool.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
