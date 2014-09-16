From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH 3] scsi: fix build errors, SCSI_FC_ATTRS needs to depend
 on SCSI && NET
Date: Mon, 15 Sep 2014 20:17:43 -0700
Message-ID: <5417ABD7.3020005@infradead.org>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com> <1410813921-24400-2-git-send-email-anish@chelsio.com>,<5417825A.4050902@infradead.org> <525DB349B3FB5444AE057A887CB2A8D88EBB11@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"eddie.wai@broadcom.com" <eddie.wai@broadcom.com>,
	"jim.epost@gmail.com" <jim.epost@gmail.com>
To: Anish Bhatt <anish@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D88EBB11@nice.asicdesigners.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/14 20:00, Anish Bhatt wrote:
> 
> Doesn't fix make warnings, but SCSI_FC_ATTRS can no longer be selected without
> NET. Though both ia64 and powerpc emit a lot of unmet dependency warnings as is 
> on defconfig


You mean these kconfig warnings?

<quote>

After merging the net tree, today's linux-next build
(powerpc ppc64_defconfig) failed like this:

warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)

</quote>

I'll look into those.
-- 
~Randy
