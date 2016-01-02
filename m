From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] xen-netback: Fine-tuning for three function
 implementations
Date: Sat, 2 Jan 2016 18:50:12 +0100
Message-ID: <56880DD4.2090806@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 18:46:45 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Delete an unnecessary assignment in connect_rings()
  Delete an unnecessary goto statement in connect_rings()
  Replace a variable initialisation by an assignment in read_xenbus_vif_flags()
  Replace a variable initialisation by an assignment in xen_register_watchers()
  Delete an unnecessary variable initialisation in xen_register_watchers()

 drivers/net/xen-netback/xenbus.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

-- 
2.6.3

