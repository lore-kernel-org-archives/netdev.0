From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] net: clean up interactions of
 CHECKSUM_PARTIAL and fragmentation
Date: Sun, 01 Nov 2015 12:02:05 -0500 (EST)
Message-ID: <20151101.120205.1917386924058908596.davem@davemloft.net>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vyasevich@gmail.com,
	bcodding@redhat.com, tom@herbertland.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKARCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:02:07 -0500
In-Reply-To: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 27 Oct 2015 22:40:38 +0100

> This series fixes wrong checksums on the wire for IPv4 and IPv6. Large
> send buffers and especially NFS lead to wrong checksums in both IPv4
> and IPv6.
> 
> CHECKSUM_PARTIAL skbs should not receive the respective fragmentations
> functions, so we add WARN_ON_ONCE to those functions to fix up those as
> soon as they get reported.
> 
> Changelog:
> v2: added v4 checks
> v3: removed WARN_ON_ONCES (advice by Tom Herbert)

Series applied, thanks.
