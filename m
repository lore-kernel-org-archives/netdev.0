From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 0/3] Fix Ethernet jumbo frames support for Armada 370
 and 38x
Date: Wed, 17 Jun 2015 17:24:58 +0200
Message-ID: <20150617172458.3e373b8a@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36667 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754602AbbFQPZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:25:02 -0400
In-Reply-To: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Simon Guinot,

On Wed, 17 Jun 2015 15:19:19 +0200, Simon Guinot wrote:

> This patch series fixes the Ethernet jumbo frames support for the SoCs
> Armada 370, 380 and 385. Unlike Armada XP, the Ethernet controller for
> this SoCs don't support TCP/IP checksumming with a frame size larger
> than 1600 bytes.
> 
> This patches should be applied to the -stable kernels 3.8 and onwards.

You should add a Fixes: tag to each commit to indicate which commit is
being fixed by your patches.

Also, I was a bit surprised by your statement that Armada 38x is also
affected by the problem, since Armada 38x is more recent than Armada
XP. but indeed, according to the Armada 38x datasheet:

  IPv4 and TCP/UDP over IPv4/IPv6 checksum generation on transmit
  frames for standard Ethernet packet size

While the Armada XP datasheet says:

  Long frames transmission (including jumbo frames), with
  IPv4/v6/TCP/UDP checksum generation

So it seems like you're right about this!

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
