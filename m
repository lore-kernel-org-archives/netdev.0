From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
Date: Thu, 11 Aug 2016 15:38:06 +0000
Message-ID: <DM5PR03MB253861AD422102B2D9F7DCC3CA1E0@DM5PR03MB2538.namprd03.prod.outlook.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
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
> Subject: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
> 
> We reset vf_inject on VF going down (netvsc_vf_down()) but we don't on
> VF removal (netvsc_unregister_vf()) so vf_inject stays 'true' while
> vf_netdev is already NULL and we're trying to inject packets into NULL
> net device in netvsc_recv_callback() causing kernel to crash.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
