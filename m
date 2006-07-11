From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BPQ] lockdep: fix false positive
Date: Tue, 11 Jul 2006 14:28:31 +0200
Message-ID: <20060711122831.GB13079@elte.hu>
References: <20060710155334.GA16338@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:62165 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1751248AbWGKMeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 08:34:06 -0400
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20060710155334.GA16338@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ralf Baechle <ralf@linux-mips.org> wrote:

> Bpqether is encapsulating AX.25 frames into ethernet frames.  There is 
> a virtual bpqether device paired with each ethernet devices, so it's 
> normal to pass through dev_queue_xmit twice for each frame which 
> triggers the locking detector.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

thanks!

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
