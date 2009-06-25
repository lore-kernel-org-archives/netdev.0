From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH v2 1/2] ucc_geth: Fix half-duplex operation for
	non-MII/RMII interfaces
Date: Thu, 25 Jun 2009 11:08:13 +0400
Message-ID: <20090625070813.GA25653@oksana.dev.rtsoft.ru>
References: <20090625010232.GA28590@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:7266 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751726AbZFYHJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 03:09:18 -0400
Content-Disposition: inline
In-Reply-To: <20090625010232.GA28590@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2009 at 05:02:32AM +0400, Anton Vorontsov wrote:
> Currently the half-duplex operation seems to not work reliably for
> RGMII PHY interfaces. It takes about 10 minutes to boot NFS rootfs
> using 10/half link, following symptoms were observed:

David, please ignore these patches, they just appear to
workaround the issue, but they don't fix the root cause (which
is unknown yet), and may cause other side to see the duplex
errors. Heh...

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
