From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 17 Mar 2015 21:39:39 +0000
Message-ID: <BY2PR0301MB0711518088A1ECF023F3AABEA0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <20150317.152324.744727347577991569.davem@redhat.com>
 <BY2PR0301MB0711AB7E8E0432AD57E29908A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
 <BY2PR0301MB07111A928395465732E9F4F0A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
 <20150317.173721.927219759019408047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150317.173721.927219759019408047.davem@davemloft.net>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, March 17, 2015 2:37 PM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; olaf@aepfle.de; netdev@vger.kernel.org;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; apw@canonical.com;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Tue, 17 Mar 2015 20:07:10 +0000
> 
> > I pulled down the net-next tree and the issue is with the first patch:
> > 0001-Drivers-hv-vmbus-Export-the-vmbus_sendpacket_pagebuf.patch
> >
> > The net-next tree is not current with Greg's tree and this patch is on code
> that
> > is in Greg's tree. This patch merely exports an API that is already in Greg's
> tree.
> > Greg wanted me to take this patch through your tree since the only user
> > of this functionality is the network driver. Any suggestions on how I should
> > proceed here.
> >
> > The second patch:
> > 0002-hyperv-Support-batched-notification.patch
> >
> > applies cleanly to your tree.
> 
> Don't create cross-tree dependencies like this.
> 
> I'm not pulling in Greg's tree to get a dependency like this.
> 
> And if I don't, I can't apply patch #2 because it will fail to
> build.
Ok; I will submit the first patch through Greg's tree.

Thanks,

K. Y
