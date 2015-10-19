From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 0/2] xfrm/crypto: unaligned access fixes
Date: Mon, 19 Oct 2015 17:23:27 -0400
Message-ID: <cover.1445286755.git.sowmini.varadhan@oracle.com>
Cc: herbert@gondor.apana.org.au, dhowells@redhat.com,
	davem@davemloft.net, zohar@linux.vnet.ibm.com,
	David.Woodhouse@intel.com, sowmini.varadhan@oracle.com,
	steffen.klassert@secunet.com
To: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A two-part patchset that fixes some "unaligned access" warnings
that showed up my sparc test machines with ipsec set up.


Sowmini Varadhan (2):
  crypto/x509: Fix unaligned access in x509_get_sig_params()
  Fix unaligned access in xfrm_notify_sa() for DELSA

 crypto/asymmetric_keys/x509_public_key.c |    5 +++--
 net/xfrm/xfrm_user.c                     |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)
