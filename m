From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on the
 send path
Date: Wed, 30 Apr 2014 14:17:04 +0000
Message-ID: <7a7fd7286bc44121839ec68c8d1458b2@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1398288285-16268-1-git-send-email-kys@microsoft.com>
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
In-Reply-To: <1398288285-16268-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: K. Y. Srinivasan [mailto:kys@microsoft.com]
> Sent: Wednesday, April 23, 2014 2:25 PM
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Cc: KY Srinivasan
> Subject: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on the
> send path
> 
> We send packets using a copy-free mechanism (this is the Guest to Host
> transport via VMBUS). While this is obviously optimal for large packets, it may
> not be optimal for small packets. Hyper-V host supports a second mechanism
> for sending packets that is "copy based". We implement that mechanism in
> this patch.
> 
> In this version of the patch I have addressed a comment from David Miller.

David,

Please let me know if there is some other issue you want addressed in this patch.

Regards,

K. Y
