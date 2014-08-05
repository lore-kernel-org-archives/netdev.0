From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Increase the buffer length for
 netvsc_channel_cb()
Date: Tue, 5 Aug 2014 20:12:42 +0000
Message-ID: <8fc1fe81db1b450685921f9ea97f8477@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1406908530-22667-1-git-send-email-haiyangz@microsoft.com>
 <20140805.130346.2080401893280146356.davem@davemloft.net>
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
To: David Miller <davem@davemloft.net>,
	"thomas1206@gmail.com" <thomas1206@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140805.130346.2080401893280146356.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, August 5, 2014 4:04 PM
> To: thomas1206@gmail.com
> Cc: netdev@vger.kernel.org; Haiyang Zhang; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Increase the buffer length for
> netvsc_channel_cb()
> 
> From: Haiyang Zhang <thomas1206@gmail.com>
> Date: Fri,  1 Aug 2014 15:55:30 +0000
> 
> > When the buffer is too small for a packet from VMBus, a bigger buffer
> will be
> > allocated in netvsc_channel_cb() and retry reading the packet from
> VMBus.
> > Increasing this buffer size will reduce the retry overhead.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: Dexuan Cui <decui@microsoft.com>
> 
> I'm not applying this, sorry.
> 
> I said that because the structure that contains this buffer is now
> larger than a page, you should allocate the CB buffer externally
> via another kmalloc() or via the page allocator.

This must have been re-sent accidentally when we are updating our 
Email server... I will update the patch and re-submit it soon.

Thanks,
- Haiyang
