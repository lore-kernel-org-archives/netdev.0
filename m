From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] IPVS fix for 3.9
Date: Sat, 27 Apr 2013 20:06:13 +0200
Message-ID: <1367085974-7750-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains a fix for a hard crash in the
SIP persistence engine available in IPVS, from Hans Schillstrom:

The problem has been there since 2.6.37, but I think it would be good
to have a fix for this into 3.9, if time allows.

Hans Schillstrom (1):
  ipvs: ip_vs_sip_fill_param() BUG: bad check of return value

 net/netfilter/ipvs/ip_vs_pe_sip.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

-- 
1.7.10.4

