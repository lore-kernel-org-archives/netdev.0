From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v10 3/5] PCI: Disable Relaxed Ordering Attributes for AMD
 A1100
Date: Mon, 14 Aug 2017 18:07:51 +0000
Message-ID: <MWHPR12MB1600654CA840BC47AFC06127C88C0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
 <1502725499-11276-4-git-send-email-dingtianhong@huawei.com>,<20170814171937.GA52656@otc-nc-03>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "mark.rutland@arm.com" <mark.rut
To: "Raj, Ashok" <ashok.raj@intel.com>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170814171937.GA52656@otc-nc-03>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Raj, Ashok <ashok.raj@intel.com>
| Sent: Monday, August 14, 2017 10:19 AM
| =A0  =20
| On Mon, Aug 14, 2017 at 11:44:57PM +0800, Ding Tianhong wrote:
| > Casey reported that the AMD ARM A1100 SoC has a bug in its PCIe
| > Root Port where Upstream Transaction Layer Packets with the Relaxed
| > Ordering Attribute clear are allowed to bypass earlier TLPs with
| > Relaxed Ordering set, it would cause Data Corruption, so we need
| > to disable Relaxed Ordering Attribute when Upstream TLPs to the
| > Root Port.
| >=20
| > Signed-off-by: Casey Leedom <leedom@chelsio.com>
| > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
| > Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
| > Acked-by: Ashok Raj <ashok.raj@intel.com>
|=20
| I can't ack this patch :-).. must be someone from AMD. Please remove my
| signature from this.

  You can go ahead and leave my name on since I'm the person who found and =
diagnosed the problem (with help from others inside Chelsio).

  If anyone on the Linux PCI List knows anyone at AMD who'd be willing to r=
espond it would be great, but as I noted earlier, I think that AMD has effe=
ctively abandoned the A1100 ("Seattle") ARM SoC, so I doubt if we'll get an=
yone from AMD to even comment now.

Casey=
