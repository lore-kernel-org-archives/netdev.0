From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: drop vlan_getnext
Date: Tue, 23 Feb 2016 12:55:55 -0500
Message-ID: <87mvqrpaz8.fsf@ketchup.mtl.sfl>
References: <201602240150.eGivp1lr%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201602240150.eGivp1lr%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kbuild test robot <lkp@intel.com> writes:

> All errors (new ones prefixed by >>):
>
>    net/dsa/slave.c: In function 'dsa_bridge_check_vlan_range':
>>> net/dsa/slave.c:215:14: error: 'struct dsa_switch_driver' has no member named 'vlan_getnext'

Indeed this applies on an under-review patchset mentioned in the cover
letter, which removes the dsa_bridge_check_vlan_range function above:

https://patchwork.ozlabs.org/patch/582234/

Even though the 2 patchsets cover different semantics, I can resend them
in a single one if necessary.

Thanks,
-v
