From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] [PATCH v2 3/3] Let host NIC driver to DMA to guest user
 space.
Date: Thu, 8 Apr 2010 17:52:25 -0700
Message-ID: <20100408175225.7577af19@nehalam>
References: <1270193410-6877-1-git-send-email-xiaohui.xin@intel.com>
	<20100402085556.75a8ff7c@nehalam>
	<97F6D3BD476C464182C1B7BABF0B0AF5C17B5C2A@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>, "mst@redhat.com" <mst@redhat.com>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C17B5C2A@shzsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Apr 2010 14:26:29 +0800
"Xin, Xiaohui" <xiaohui.xin@intel.com> wrote:

> >How do you deal with the DoS problem of hostile user space app posting huge
> >number of receives and never getting anything.   
> 
> That's a problem we are trying to deal with. It's critical for long term.
> Currently, we tried to limit the pages it can pin, but not sure how much is reasonable.
> For now, the buffers submitted is from guest virtio-net driver, so it's safe in some extent
> just for now.

It is critical even now. Once you get past toy benchmarks you will see things like
Java processes with 1000 threads all reading at once. 
