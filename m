From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Thu, 04 Dec 2014 23:03:30 +0100
Message-ID: <5480DA32.8000201@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net> <547B4886.4080406@users.sourceforge.net> <547B
 496E.604@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com> <547C82A6.2030808@users.sourceforge.net> <547CA157.1080401@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <547CA157.1080401@cogentembedded.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 Dec 2014 22:50:28 +0100

Further update suggestions were taken into account before and after a patch
was applied from static source code analysis.

Markus Elfring (6):
  Replacement of a printk() call by pr_warn() in mppe_rekey()
  Fix indentation
  Deletion of unnecessary checks before the function call "kfree"
  Less function calls in mppe_alloc() after error detection
  Delete an unnecessary assignment in mppe_alloc()
  Delete another unnecessary assignment in mppe_alloc()

 drivers/net/ppp/ppp_mppe.c | 49 +++++++++++++++++++---------------------------
 1 file changed, 20 insertions(+), 29 deletions(-)

-- 
2.1.3

