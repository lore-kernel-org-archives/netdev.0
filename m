From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hyperv: Fix the NETIF_F_SG flag setting in netvsc
Date: Wed, 17 Jul 2013 11:57:15 -0700 (PDT)
Message-ID: <20130717.115715.965921785189776151.davem@davemloft.net>
References: <1374040880-20468-1-git-send-email-haiyangz@microsoft.com>
 <8906250c5dfc4f7ab0d84019bf7b9a44@SN2PR03MB061.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 haiyangz@microsoft.com
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <8906250c5dfc4f7ab0d84019bf7b9a44@SN2PR03MB061.namprd03.prod.outlook.com>
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

From: KY Srinivasan <kys@microsoft.com>
Date: Wed, 17 Jul 2013 11:40:41 +0000

> 
> 
>> -----Original Message-----
>> From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
>> Sent: Wednesday, July 17, 2013 2:01 AM
>> To: davem@davemloft.net; netdev@vger.kernel.org
>> Cc: Haiyang Zhang; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-
>> kernel@vger.kernel.org; devel@linuxdriverproject.org
>> Subject: [PATCH net] hyperv: Fix the NETIF_F_SG flag setting in netvsc
>> 
>> SG mode is not currently supported by netvsc, so remove this flag for now.
>> Otherwise, it will be unconditionally enabled by commit ec5f0615642
>>     "Kill link between CSUM and SG features"
>> Previously, the SG feature is disabled because CSUM is not set here.
>> 
>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> We would need to apply this patch to 3.9 and 3.10 as well that are currently broken.

I have already queued this patch up for -stable submission.
