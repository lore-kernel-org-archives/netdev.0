From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Fri, 23 Jul 2010 10:08:14 +0200
Message-ID: <4C494DEE.3010101@redhat.com>
References: <20100721150732.GR7497@gospo.rdu.redhat.com> <20100721102816.4bef5ada@nehalam> <20100721.103249.107094774.davem@davemloft.net> <201007211129.48288.leedom@chelsio.com> <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com> <4C47EAF3.3080602@redhat.com> <2408F875-69BE-45D3-8605-4AE5CDA4601C@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	andy@greyhouse.net, harald@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2408F875-69BE-45D3-8605-4AE5CDA4601C@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 02:26, Casey Leedom wrote:
> 
>  Or you simply don't have the VF Driver loaded in the "Domain 0" Control OS.  When we install the cxgb4 PF Driver with "num_vf=..." this enables the PCI-E SR-IOV Capabilities within the various PFs and the corresponding VF PCI Devices are instantiated and discovered by the Domain 0 Linux OS.  But without a cxgb4vf VF Driver loaded, those devices just sit there  available for "Device Assignment" to VMs.
> 

Just out of curiosity, how do you prevent the VF driver from getting
loaded in the host? Except from blacklisting it.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
