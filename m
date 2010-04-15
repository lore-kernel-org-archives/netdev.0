From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM
	virtio-net.
Date: Thu, 15 Apr 2010 12:03:24 +0300
Message-ID: <20100415090324.GA15135@redhat.com>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <1270805865-16901-2-git-send-email-xiaohui.xin@intel.com> <201004141655.21885.arnd@arndb.de> <97F6D3BD476C464182C1B7BABF0B0AF5C18969A5@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C18969A5@shzsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 15, 2010 at 05:01:10PM +0800, Xin, Xiaohui wrote:
> >It smells like a layering violation to look at the iocb->private field
> >from a lower-level driver. I would have hoped that it's possible to implement
> >this without having this driver know about the higher-level vhost driver
> >internals. Can you explain why this is needed?
> 
> I don't like this too, but since the kiocb is maintained by vhost with a list_head.
> And mp device is responsible to collect the kiocb into the list_head,
> We need something known by vhost/mp both.

Can't vhost supply a kiocb completion callback that will handle the list?

-- 
MST
