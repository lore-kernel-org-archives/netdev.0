From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces with random MAC address
Date: Fri, 23 Jul 2010 09:35:58 -0700
Message-ID: <201007230935.59010.leedom@chelsio.com>
References: <20100721150732.GR7497@gospo.rdu.redhat.com> <2408F875-69BE-45D3-8605-4AE5CDA4601C@chelsio.com> <4C494DEE.3010101@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	andy@greyhouse.net, harald@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C494DEE.3010101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Stefan Assmann <sassmann@redhat.com>
| Date: Friday, July 23, 2010 01:08 am
| 
| On 23.07.2010 02:26, Casey Leedom wrote:
| >  Or you simply don't have the VF Driver loaded in the "Domain 0" Control
| >  OS.  When we install the cxgb4 PF Driver with "num_vf=..." this enables
| >  the PCI-E SR-IOV Capabilities within the various PFs and the
| >  corresponding VF PCI Devices are instantiated and discovered by the
| >  Domain 0 Linux OS.  But without a cxgb4vf VF Driver loaded, those
| >  devices just sit there available for "Device Assignment" to VMs.
| 
| Just out of curiosity, how do you prevent the VF driver from getting
| loaded in the host? Except from blacklisting it.

  I don't install them. :-)

  I'm actually fairly unfamiliar with the details of managing/administering 
Linux systems so I'm guessing that there are much better ways of controlling for 
which devices a Linux system will attempt to load drivers.  For instance, I 
didn't know about the concept of "blacklisting" a driver.

Casey
