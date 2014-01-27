From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] net: hyperv: initialize link status correctly
Date: Mon, 27 Jan 2014 16:05:03 +0000
Message-ID: <366785442d3b42d593f3c5df3f867ddd@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1390807854-4469-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang@redhat.com>, KY Srinivasan <kys@microsoft.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1390807854-4469-1-git-send-email-jasowang@redhat.com>
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
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Monday, January 27, 2014 2:31 AM
> To: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Jason Wang
> Subject: [PATCH net] net: hyperv: initialize link status correctly
> 
> Call netif_carrier_on() after register_device(). Otherwise it won't work since
> the device was still in NETREG_UNINITIALIZED state.
> 
> Fixes a68f9614614749727286f675d15f1e09d13cb54a
> (hyperv: Fix race between probe and open calls)
> 
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Reported-by: Di Nie <dnie@redhat.com>
> Tested-by: Di Nie <dnie@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

I'm working on a fix for this, and will submit it soon.

Thanks,
- Haiyang
