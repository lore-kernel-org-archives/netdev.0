From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] fm10k:Fix error handling in the
 function	fm10k_resume
Date: Wed, 28 Oct 2015 22:40:23 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E27221EC0@ORSMSX103.amr.corp.intel.com>
References: <1445098842-28260-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445098842-28260-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Nicholas Krause
Sent: Saturday, October 17, 2015 9:21 AM
To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Cc: linux-kernel@vger.kernel.org; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org
Subject: [Intel-wired-lan] [PATCH] fm10k:Fix error handling in the function fm10k_resume

This fixes error handling to proper check if the call to the function fm10k_mbx_request_irq has failed by returning a error code and if so return immediately to the caller of fm10k_resume to properly signal a failure has occurred when accepting to resume this network

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---

Tested-by: Krishneil SIngh <krishneil.k.singh@intel.com>
