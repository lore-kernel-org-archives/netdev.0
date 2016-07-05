From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 5 Jul 2016 06:46:24 +0000
Message-ID: <CO2PR03MB21821C4832602D8464D9C092BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <CO2PR03MB21823DBFD52A5CF4F96DB712BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160704.232704.1161688488597729534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "vkuznets@redhat.com" <vkuznets@redhat.com>, "cavery@redhat.com"
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>,
 "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160704.232704.1161688488597729534.davem@davemloft.net>
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
> Sent: Tuesday, July 5, 2016 14:27
> To: Dexuan Cui <decui@microsoft.com>
> Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Tue, 5 Jul 2016 01:58:31 +0000
> 
> > Not sure if you had a chance to review this version.
> 
> Why me?
I just think you're the most responsive reviewer. :-)

> Other people have to review this too.
Sure. Let me try to ask more people to review this.
 
> > Now I have a question: may I split the include/linux/socket.h change
> > and ask you to pre-allocate the number for AF_HYPERV to allow
> > backporting of Hyper-V Sockets to distro kernels, and to make sure
> > that applications using the socket type will work with the backport
> > as well as the upstream kernel?
> 
> Sorry, I'm not going to do this.
> 
> You cannot commit anything in userspace to this value anywhere
> until it is accepted upstream.
Got it. Thanks for the explanation! 

Thanks,
-- Dexuan
