From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] ISDN-Gigaset: Fine-tuning for three function
 implementations
Date: Mon, 26 Sep 2016 17:37:15 +0200
Message-ID: <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 26 Sep 2016 17:27:17 +0200

Some update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Use kmalloc_array() in two functions
  Improve another size determination in gigaset_initcs()
  Delete an error message for a failed memory allocation
  Release memory in gigaset_initcs() after an allocation failure
  Enclose two expressions for the sizeof operator by parentheses

 drivers/isdn/gigaset/common.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

-- 
2.10.0

