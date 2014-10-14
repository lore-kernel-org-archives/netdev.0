From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v2] hyperv: Add handling of IP header with option
 field in netvsc_set_hash()
Date: Tue, 14 Oct 2014 21:47:33 +0000
Message-ID: <e660408eec9a48f088ae8a99036e223e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1413324988-8863-1-git-send-email-haiyangz@microsoft.com>
 <20141014.173717.1412701736631211553.davem@davemloft.net>
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
In-Reply-To: <20141014.173717.1412701736631211553.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, October 14, 2014 5:37 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v2] hyperv: Add handling of IP header with option
> field in netvsc_set_hash()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 14 Oct 2014 15:16:28 -0700
> 
> > In case that the IP header has optional field at the end, this patch
> > will get the port numbers after that field, and compute the hash.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Instead of adding hack after hack after hack to your internal header parser, just
> use the generic flow dissector we already have in the kernel to fetch out the
> values you need.
> 
> __skb_flow_get_ports() etc.

Thanks. I will update the patch.

- Haiyang
