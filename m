From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net 3/4] hv_netvsc: protect module refcount by checking
 net_device_ctx->vf_netdev
Date: Thu, 11 Aug 2016 15:38:06 +0000
Message-ID: <DM5PR03MB253806F92978B1BF37FF306ECA1E0@DM5PR03MB2538.namprd03.prod.outlook.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-4-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-4-git-send-email-vkuznets@redhat.com>
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
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Thursday, August 11, 2016 6:59 AM
> To: netdev@vger.kernel.org
> Cc: devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; Haiyang
> Zhang <haiyangz@microsoft.com>; KY Srinivasan <kys@microsoft.com>
> Subject: [PATCH net 3/4] hv_netvsc: protect module refcount by checking
> net_device_ctx->vf_netdev
> 
> We're not guaranteed to see NETDEV_REGISTER/NETDEV_UNREGISTER
> notifications
> only once per VF but we increase/decrease module refcount unconditionally.
> Check vf_netdev to make sure we don't take/release it twice. We presume
> that only one VF per netvsc device may exist.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
