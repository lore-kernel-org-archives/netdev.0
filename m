From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCHv2 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Tue, 28 Sep 2010 17:53:50 +0200
Message-ID: <cover.1285687738.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:58296 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941Ab0I1Pwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 11:52:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This an updated version of the patches. For reference, introduction of
the feature is here http://thread.gmane.org/gmane.linux.network/172941
Just tell me if you prefer I resend the full intro each time.

Compared to initial version, this v2 is

 - against net-next-2.6
 - fixed and more exhaustively build tested for various kernel
   configuration (w/ and w/o IPv6, IPv4, MIPv6, XFRM*, RO, ...).
   It adds some #ifdef but I did not found good ways to spare those.
 - built and tested on both current linux-2.6 and net-next-2.6 (*)

Comments welcome.

Cheers,

a+

(*): stripped from latest stats patches from Eric (crash at boot) until
     associated fixes get included tomorrow

