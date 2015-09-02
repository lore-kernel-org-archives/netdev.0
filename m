From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net 0/2] couple of sctp fixes for 0ca50d12fe46
Date: Wed,  2 Sep 2015 16:20:20 -0300
Message-ID: <cover.1441220305.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbbIBTUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 15:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are two fixes for sctp after my patch on 0ca50d12fe46 ("sctp: fix
src address selection if using secondary addresses")

The first, fix a dst leak on those it decided to skip.

The second, adds the fallback on src selection that Vlad had asked
about. Unfortunatelly a lot of ipvs setups relies on the old behavior
and I don't see a better fix for it.

Please consider both to -stable tree.

Thanks!

Marcelo Ricardo Leitner (2):
  sctp: fix dst leak
  sctp: add routing output fallback

 net/sctp/protocol.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

-- 
2.4.3
