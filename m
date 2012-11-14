From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH 1/3] net: Add support for hardware-offloaded
 encapsulation
Date: Wed, 14 Nov 2012 12:23:57 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BF5CF01@SJEXCHMB06.corp.ad.broadcom.com>
References: <1352427483-4380-1-git-send-email-joseph.gasparakis@intel.com>
 <1352427483-4380-2-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "Joseph Gasparakis" <joseph.gasparakis@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352427483-4380-2-git-send-email-joseph.gasparakis@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Joseph Gasparakis
> Sent: Friday, November 09, 2012 4:18 AM
> To: davem@davemloft.net; shemminger@vyatta.com; chrisw@sous-sol.org
> Cc: Joseph Gasparakis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> Peter P Waskiewicz Jr
> Subject: [PATCH 1/3] net: Add support for hardware-offloaded encapsulation
> 
> This patch adds support in the kernel for offloading in the NIC Tx and Rx
> checksumming for encapsulated packets (such as VXLAN and IP GRE)
> 
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
[D.K.] 

>  	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets.
> */
> +	NETIF_F_HW_CSUM_ENC_BIT,	/* Can checksum all inner headers */
>  	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over
> IPV6 */

Also #define NETIF_F_HW_CSUM_ENC should be added
