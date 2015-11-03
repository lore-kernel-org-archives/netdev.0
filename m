From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] batman-adv: Deletion of a few unnecessary checks
Date: Tue, 3 Nov 2015 21:45:43 +0100
Message-ID: <56391CF7.9080400@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 3 Nov 2015 21:34:29 +0100

Further update suggestions were taken into account after a patch
was applied from static source code analysis.

Markus Elfring (3):
  Delete an unnecessary check before the function call "batadv_softif_vlan_free_ref"
  Split a condition check
  Less function calls in batadv_is_ap_isolated() after error detection

 net/batman-adv/translation-table.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

-- 
2.6.2
