From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCHv4 net-next-2.6 0/5] Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Mon, 04 Oct 2010 08:24:51 +0200
Message-ID: <cover.1286139128.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:57146 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253Ab0JDGYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 02:24:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is version 4 of the patches. Compared to previous version:

 - symbols which need not be exported are no more exported
 - s/printk(KERNINFO, ...)/pr_info()/ in net/ipv6/mip6.c (my code
   and existing one)
 - I also refactored some initialization code for mip6 states
   (by introduced mip6_state_init_sanity_check())

After the discussion with Herbert, I decided to leave input handlers
as they are at the moment until I have some additional time to dig on
it. At least, it's safe.

Regarding reject handler() (to warn user space so that a Binding Error
can be sent), it still does nothing yet.

Herbert, if you read this, can you take a quick look at patches 1/5 and
4/5 to tell if the changes are acceptable for IPsec users.

Cheers,

a+
