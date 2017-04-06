From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [PATCH rfc 0/6] Automatic affinity settings for nvme over rdma
Date: Thu, 6 Apr 2017 11:34:03 +0300
Message-ID: <09b4dcb4-d0ab-43b7-5f1c-394ecfcce2f0@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
 <86ed1762-a990-691f-e043-3d7dcac8fe85@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <86ed1762-a990-691f-e043-3d7dcac8fe85-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Hi Sagi,

Hey Max,

> the patchset looks good and of course we can add support for more
> drivers in the future.
> have you run some performance testing with the nvmf initiator ?

I'm limited by the target machine in terms of IOPs, but the host shows
~10% cpu usage decrease, and latency improves slightly as well
which is more apparent depending on which cpu I'm running my IO
thread (due to the mismatch in comp_vectors and queue mappings
some queues have irq vectors mapped to a core on a different numa
node.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
