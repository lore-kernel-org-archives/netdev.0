From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Increase the buffer length for
 netvsc_channel_cb()
Date: Mon, 4 Aug 2014 22:34:55 +0000
Message-ID: <14d84b7541894b16badd0513f581361a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1407180825-21832-1-git-send-email-haiyangz@microsoft.com>
 <20140804.150842.507300261765977637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140804.150842.507300261765977637.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, August 4, 2014 6:09 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Increase the buffer length for
> netvsc_channel_cb()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Mon,  4 Aug 2014 12:33:45 -0700
> 
> > When the buffer is too small for a packet from VMBus, a bigger buffer
> > will be allocated in netvsc_channel_cb() and retry reading the packet from
> VMBus.
> > Increasing this buffer size will reduce the retry overhead.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: Dexuan Cui <decui@microsoft.com>
> 
> Now netvsc_device is significantly larger than a page, you should probably
> therefore allocate netvsc_device->cb_buffer indirectly instead of inlining it into
> the structure.

I will make this update.
Thanks,
- Haiyang
