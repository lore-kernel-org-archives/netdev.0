From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/5] sky2: Avoid rewinding sky2->tx_prod
Date: Mon, 3 Aug 2009 08:48:45 -0700
Message-ID: <20090803084845.2776b1a6@nehalam>
References: <392fb48f0908030407j69f32c6qed9529f1219ee474@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36733 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755325AbZHCPsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 11:48:50 -0400
In-Reply-To: <392fb48f0908030407j69f32c6qed9529f1219ee474@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree this is good, but more explanation in the commit log would be helpful
as a record.

Note: the unwind code should not ever be called on x86, since dma_mapping always
succeeds. 


Acked-by: Stephen Hemminger <shemminger@vyatta.com>
