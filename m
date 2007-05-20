From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Sun, 20 May 2007 02:36:11 -0400
Message-ID: <464FEC5B.1060708@garzik.org>
References: <464B7127.5080502@gmail.com>	<20070518180903.GC3492@tuxdriver.com>	<1179622601.9453.4.camel@xo-28-0B-88.localdomain>	<464FA894.8090008@garzik.org> <20070519222014.45f11138@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Florin Malita <fmalita@gmail.com>, marcelo@kvack.org,
	linville@redhat.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60295 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756888AbXETGhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 May 2007 02:37:16 -0400
In-Reply-To: <20070519222014.45f11138@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The skb is always consumed so the the return value is informational only.

Yes, this is true.  Handing off an skb to netif_rx() relieves the driver 
of further responsibility for it.

	Jeff


