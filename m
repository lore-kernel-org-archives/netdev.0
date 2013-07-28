From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] pktgen: Add UDPCSUM flag to support UDP
 checksums
Date: Sat, 27 Jul 2013 22:17:35 -0700 (PDT)
Message-ID: <20130727.221735.366623812908647883.davem@davemloft.net>
References: <84311bc33840c8d77ab4286729df86ec85cdd411.1374768622.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	greearb@candelatech.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3G1FRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 01:17:36 -0400
In-Reply-To: <84311bc33840c8d77ab4286729df86ec85cdd411.1374768622.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 25 Jul 2013 18:12:18 +0200

> UDP checksums are optional, hence pktgen has been omitting them in
> favour of performance. The optional flag UDPCSUM enables UDP
> checksumming. If the output device supports hardware checksumming
> the skb is prepared and marked CHECKSUM_PARTIAL, otherwise the
> checksum is generated in software.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good, applied, thanks everyone.
