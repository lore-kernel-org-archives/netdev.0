From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: fix tx checksum offload for big endian
Date: Sat, 03 Nov 2012 15:30:44 -0400 (EDT)
Message-ID: <20121103.153044.759986344361039924.davem@davemloft.net>
References: <1351853060-2330-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jose.ventura@efacec.com
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab2KCTaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:30:46 -0400
In-Reply-To: <1351853060-2330-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Fri,  2 Nov 2012 10:44:20 +0000

> f7b2927 introduced tx checksum offload support for smsc95xx,
> and enabled it by default. This feature doesn't take
> endianness into account, so causes most tx to fail on
> those platforms.
> 
> This patch fixes the problem fully by adding the missing
> conversion.
> 
> An alternate workaround is to disable TX checksum offload
> on those platforms. The cpu impact of this feature is very low.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied and queued up for -stable, thanks.
