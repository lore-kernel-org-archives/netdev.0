From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 02:01:26 -0700 (PDT)
Message-ID: <20110705.020126.719520789098567233.davem@davemloft.net>
References: <4E12C2B2.9060007@inliniac.net>
	<20110705.010254.1376215864913143868.davem@davemloft.net>
	<4E12CFC7.3070902@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085Ab1GEJBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:01:36 -0400
In-Reply-To: <4E12CFC7.3070902@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Victor Julien <victor@inliniac.net>
Date: Tue, 05 Jul 2011 10:48:07 +0200

> On 07/05/2011 10:02 AM, David Miller wrote:
>> Would you prefer to receive the frags individually?
> 
> Ideally what we receive is the same as on the wire, but I think your
> solution would be fine.
> 
> In addition to the reassembled packet, having an option to receive the
> individual frags as well would be of use. Suricata (and Snort as well)
> has it's own defrag code that does anomaly detection. I can see a use
> case where just for that anomaly detection we'd still want to see the
> frags. In that case it wouldn't be a problem that they would all go to
> fanout 0.

Ok, I'm about to post a new set of patches that add the pre-defragmentation
support.
