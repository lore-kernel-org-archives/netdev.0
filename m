From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH ipsec 0/3] vti/vti6: minor tweaks + one fix
Date: Fri,  9 May 2014 23:43:39 +0200
Message-ID: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:60855 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbaEIVoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 17:44:03 -0400
Received: by mail-ee0-f48.google.com with SMTP id e49so3000057eek.7
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 14:44:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

this series addresses a few issues related to VTI. The first patch fixes
a bug in the vti6 module calling unregister_pernet_device() twice in the
error path. That's probably material for ipsec.git.
The second patch simplifies the error handling path in module init/fini
of vti6. The third patch does the same for vti. Those two are probably
material for ipsec-next.git as we're at -rc5 already. But I leave that
decision to you.

Please apply!

Mathias Krause (3):
  vti6: Don't unregister pernet ops twice on init errors
  vti6: Simplify error handling in module init and exit
  vti: Simplify error handling in module init and exit

 net/ipv4/ip_vti.c  |   54 +++++++++++++++++---------------------------
 net/ipv6/ip6_vti.c |   54 ++++++++++++++++----------------------------
 2 files changed, 41 insertions(+), 67 deletions(-)

-- 
1.7.10.4
