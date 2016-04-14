From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] hv_netvsc: Implement support for VF drivers on Hyper-V
Date: Thu, 14 Apr 2016 19:08:29 +0000
Message-ID: <SN2PR03MB1919961BC06B8CBC7140EE96A0970@SN2PR03MB1919.namprd03.prod.outlook.com>
References: <1460591887-24671-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KY Srinivasan <kys@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460591887-24671-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: K. Y. Srinivasan [mailto:kys@microsoft.com]
> Sent: Wednesday, April 13, 2016 4:58 PM
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Cc: KY Srinivasan <kys@microsoft.com>
> Subject: [PATCH 1/1] hv_netvsc: Implement support for VF drivers on Hyper-
> V
> 
> Support VF drivers on Hyper-V. On Hyper-V, each VF instance presented to
> the guest has an associated synthetic interface that shares the MAC address
> with the VF instance. Typically these are bonded together to support
> live migration. By default, the host delivers all the incoming packets
> on the synthetic interface. Once the VF is up, we need to explicitly switch
> the data path on the host to divert traffic onto the VF interface. Even after
> switching the data path, broadcast and multicast packets are always
> delivered
> on the synthetic interface and these will have to be injected back onto the
> VF interface (if VF is up).
> This patch implements the necessary support in netvsc to support Linux
> VF drivers.

David,

Please drop this patch. I just discovered a merge issue and I am going to resubmit this
patch.

Regards,

K. Y
