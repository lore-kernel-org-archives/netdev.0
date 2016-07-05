From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 5 Jul 2016 01:58:31 +0000
Message-ID: <CO2PR03MB21823DBFD52A5CF4F96DB712BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: "davem@davemloft.net" <davem@davemloft.net>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com"
 <jasowang@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Cathy Avery
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
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

> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Dexuan Cui
> Sent: Thursday, June 30, 2016 23:59
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index b5cc5a6..0b68b58 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -202,8 +202,9 @@ struct ucred {
>  #define AF_VSOCK	40	/* vSockets			*/
>  #define AF_KCM		41	/* Kernel Connection Multiplexor*/
>  #define AF_QIPCRTR	42	/* Qualcomm IPC Router          */
> +#define AF_HYPERV	43	/* Hyper-V Sockets              */
> 
> -#define AF_MAX		43	/* For now.. */
> +#define AF_MAX		44	/* For now.. */

Hi David,
Not sure if you had a chance to review this version.
Now I have a question: may I split the include/linux/socket.h change
and ask you to pre-allocate the number for AF_HYPERV to allow
backporting of Hyper-V Sockets to distro kernels, and to make sure that
applications using the socket type will work with the backport as well
as the upstream kernel?

Thanks,
-- Dexuan
