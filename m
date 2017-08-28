From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v3 net-next 1/1] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Mon, 28 Aug 2017 23:30:08 +0000
Message-ID: <KL1P15301MB0008C9E4CA43C17BFF47431FBF9E0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <PS1P15301MB00117CF517E0EFF548C9F572BF980@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
 <20170828.153852.1182668029079177666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>, "olaf@aepfle.de" <olaf@aepfle.de>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 "georgezhang@vmware.com" <georgezhang@vmware.com>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "dave.scott@docker.com" <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "marcelo.cerri@canonical.com" <marcelo.cerri@canonical.com>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
 "apw@canonical.com" <apw@canonical.com>, "joe@perches.com" <joe@perches.com>,
 "vkuznets@redhat.com" <vkuznets@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170828.153852.1182668029079177666.davem@davemloft.net>
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

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, August 28, 2017 15:39
> From: Dexuan Cui <decui@microsoft.com>
> Date: Sat, 26 Aug 2017 04:52:43 +0000
> 
> >
> > Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> > mechanism between the host and the guest. It uses VMBus ringbuffer as
> the
> > transportation layer.
> >
> > With hv_sock, applications between the host (Windows 10, Windows
> Server
> > 2016 or newer) and the guest can talk with each other using the traditional
> > socket APIs.
> >
> > Signed-off-by: Dexuan Cui <decui@microsoft.com>
> 
> Applied, thank you.

Thanks a lot!

There are some supporting patches still pending in the VMBus driver.
I'll make sure they go in through the char-misc tree.

Thanks,
-- Dexuan
