From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] netlabel: Deletion of a few unnecessary checks
Date: Sat, 31 Jan 2015 22:14:30 +0100
Message-ID: <54CD45B6.6010703@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 31 Jan 2015 22:00:14 +0100

Further update suggestions were taken into account after patches were applied
from static source code analysis.

Markus Elfring (3):
  Deletion of an unnecessary check before the function call "cipso_v4_doi_putdef"
  Deletion of an unnecessary check before the function call "cipso_v4_doi_free"
  Less function calls in netlbl_mgmt_add_common() after error detection

 net/netlabel/netlabel_cipso_v4.c |  3 +--
 net/netlabel/netlabel_mgmt.c     | 47 ++++++++++++++++++++--------------------
 2 files changed, 24 insertions(+), 26 deletions(-)

-- 
2.2.2
