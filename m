From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH rfc 0/6] Automatic affinity settings for nvme over rdma
Date: Wed, 12 Apr 2017 08:34:26 +0200
Message-ID: <20170412063426.GA20883@lst.de>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me> <14fd128d-7155-ab13-492f-952f072808d5@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sagi Grimberg <sagi@grimberg.me>, linux-rdma@vger.kernel.org,
        linux-nvme@lists.infradead.org, linux-block@vger.kernel.org,
        netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-block-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <14fd128d-7155-ab13-492f-952f072808d5@opengridcomputing.com>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 01:05:50PM -0500, Steve Wise wrote:
> I'll test cxgb4 if you convert it. :)

That will take a lot of work.  The problem with cxgb4 is that it
allocatesd all the interrupts at device enable time, but then only
allocates them to ULDs when they attached, while this scheme assumes
as way to map out queues / vectors at initialization time.
