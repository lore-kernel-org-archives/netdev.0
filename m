From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH rfc 6/6] nvme-rdma: use intelligent affinity based
        queue mappings
Date: Tue, 4 Apr 2017 08:34:44 +0200
Message-ID: <20170404063444.GF8978@lst.de>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me> <1491140492-25703-7-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <linux-block-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1491140492-25703-7-git-send-email-sagi@grimberg.me>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 02, 2017 at 04:41:32PM +0300, Sagi Grimberg wrote:
> Use the geneic block layer affinity mapping helper. Also,

          generic

>  	nr_io_queues = min(opts->nr_io_queues, num_online_cpus());
> +	nr_io_queues = min_t(unsigned int, nr_io_queues,
> +				ibdev->num_comp_vectors);
> +

Add a comment here?

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
