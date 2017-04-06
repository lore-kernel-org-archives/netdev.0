From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [PATCH rfc 6/6] nvme-rdma: use intelligent affinity based queue
 mappings
Date: Thu, 6 Apr 2017 11:30:02 +0300
Message-ID: <d896e706-ae78-6be1-dd21-fa73150537b4@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
 <1491140492-25703-7-git-send-email-sagi@grimberg.me>
 <20170404063444.GF8978@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-block-owner@vger.kernel.org>
In-Reply-To: <20170404063444.GF8978@lst.de>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> Use the geneic block layer affinity mapping helper. Also,
>
>           generic
>
>>  	nr_io_queues = min(opts->nr_io_queues, num_online_cpus());
>> +	nr_io_queues = min_t(unsigned int, nr_io_queues,
>> +				ibdev->num_comp_vectors);
>> +
>
> Add a comment here?

Will do
