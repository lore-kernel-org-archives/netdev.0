From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 1/1] ixgbe: use kzalloc for allocating
 one	thing
Date: Wed, 2 Sep 2015 02:24:03 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271B565B@ORSMSX103.amr.corp.intel.com>
References: <1434686875-13040-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434686875-13040-1-git-send-email-maninder1.s@samsung.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Maninder Singh
Sent: Thursday, June 18, 2015 9:08 PM
To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse <jesse.brandeburg@intel.com>; Nelson, Shannon <shannon.nelson@intel.com>; Wyborny, Carolyn <carolyn.wyborny@intel.com>; Skidmore, Donald C <donald.c.skidmore@intel.com>; Vick, Matthew <matthew.vick@intel.com>; Ronciak, John <john.ronciak@intel.com>; Williams, Mitch A <mitch.a.williams@intel.com>; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Cc: Maninder Singh <maninder1.s@samsung.com>; pankaj.m@samsung.com
Subject: [Intel-wired-lan] [PATCH 1/1] ixgbe: use kzalloc for allocating one thing

Use kzalloc rather than kcalloc(1..

The semantic patch that makes this change is as follows:

// <smpl>
@@
@@

- kcalloc(1,
+ kzalloc(
          ...)
// </smpl>

and removing checkpatch below CHECK:
CHECK: Prefer kzalloc(sizeof(*fwd_adapter)...) over kzalloc(sizeof(struct ixgbe_fwd_adapter)...)

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Vaneet Narang <v.narang@samsung.com>
---
 
Tested-By: Krishneil Singh <krishneil.k.singh@intel.com>
