From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Fri, 19 Apr 2013 20:57:24 +0000
Message-ID: <81a2f14c2a3d4436b713bc4ca4a79cfa@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1366151150-14859-1-git-send-email-haiyangz@microsoft.com>
 <20130419.165006.1200833792933507239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130419.165006.1200833792933507239.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, April 19, 2013 4:50 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 16 Apr 2013 15:25:50 -0700
> 
> > Fixed: warning: cast from pointer to integer of different size
> >
> > The Hyper-V hosts always use 64 bit request id. The guests can have 32
> > or 64 bit pointers which equal to the ulong type size. So we cast it to ulong
> type.
> > And, assigning 32bit integer to 64 bit variable works fine.
> >
> > The VMBus returns the same id in the completion packet. But the value
> > has no effect on the host side.
> >
> > Reported-by: kbuild test robot <fengguang.wu@intel.com>
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Such build warning fixes are not appropriate for 'net' at this time, and this
> patch does not apply to 'net-next', so I'm dropping this entirely.

OK. I will re-submit it to net-next after the recent patch causing the warning
is merged into the net-next tree.

Thanks,
- Haiyang
