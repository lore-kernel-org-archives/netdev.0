From: David Miller <davem@davemloft.net>
Subject: Re: [BPQ] lockdep: fix false positive
Date: Mon, 10 Jul 2006 11:24:58 -0700 (PDT)
Message-ID: <20060710.112458.79244879.davem@davemloft.net>
References: <20060710155334.GA16338@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mingo@elte.hu,
	arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20933
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422744AbWGJSYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:24:15 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060710155334.GA16338@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 10 Jul 2006 16:53:34 +0100

> Bpqether is encapsulating AX.25 frames into ethernet frames.  There is a
> virtual bpqether device paired with each ethernet devices, so it's normal
> to pass through dev_queue_xmit twice for each frame which triggers the
> locking detector.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
