From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] fm10k:Fix error handling in the
 function	fm10k_setup_tc
Date: Tue, 27 Oct 2015 17:23:12 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E27221461@ORSMSX103.amr.corp.intel.com>
References: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Nicholas Krause
Sent: Tuesday, October 20, 2015 2:05 PM
To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Cc: linux-kernel@vger.kernel.org; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org
Subject: [Intel-wired-lan] [PATCH] fm10k:Fix error handling in the function fm10k_setup_tc

This fixes error handling in the function fm10k_setup_tc to properly check if the call to the function fm10k_open has failed by returning a error and if so return immediately to the caller of the function fm10k_setup_tc to properly signal this non recoverable failure.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---

Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
