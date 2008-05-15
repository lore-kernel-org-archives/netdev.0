From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 20:25:04 +0200
Message-ID: <20080515182504.GB2936@ami.dom.local>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk> <482C6040.9030808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kingsley Foreman <kingsley@internode.com.au>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:35784 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbYEOS0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 14:26:25 -0400
Received: by nf-out-0910.google.com with SMTP id d3so226621nfc.21
        for <netdev@vger.kernel.org>; Thu, 15 May 2008 11:26:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <482C6040.9030808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2008 at 06:09:36PM +0200, Patrick McHardy wrote:
...
> Do things improve if you set txqueuelen to a larger value
> *before* configuring the qdiscs?

BTW, I hope it was *before*, but since pfifo_fast_enqueue() uses
"qdisc->dev->tx_queue_len" does it really matter? (Until it's
before the test of course...)

Jarek P.
