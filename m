From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] fm10k: Use seq_putc() in
        fm10k_dbg_desc_break()
Date: Mon, 18 Sep 2017 16:59:52 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E64AF65B8@ORSMSX103.amr.corp.intel.com>
References: <4f8686c6-76cb-3d12-934e-6af67b6f084b@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4f8686c6-76cb-3d12-934e-6af67b6f084b@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of SF Markus Elfring
> Sent: Monday, May 8, 2017 9:18 AM
> To: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>
> Cc: kernel-janitors@vger.kernel.org; LKML <linux-kernel@vger.kernel.org>
> Subject: [Intel-wired-lan] [PATCH] fm10k: Use seq_putc() in
> fm10k_dbg_desc_break()
> 
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 8 May 2017 18:10:39 +0200
> 
> Two single characters should be put into a sequence.
> Thus use the corresponding function "seq_putc".
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---

Tested-by: Krishneil Singh  <krishneil.k.singh@intel.com>
