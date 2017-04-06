From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [PATCH rfc 5/6] block: Add rdma affinity based queue mapping
 helper
Date: Thu, 6 Apr 2017 12:23:59 +0300
Message-ID: <e1ea43dd-c44b-4b2f-f381-1195fd082609@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
 <1491140492-25703-6-git-send-email-sagi@grimberg.me>
 <becb84ac-7819-a207-56b1-70f16cb80e42@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <becb84ac-7819-a207-56b1-70f16cb80e42-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> shouldn't you include  <linux/kobject.h> and <linux/blkdev.h> like in
> commit 8ec2ef2b66ea2f that fixes blk-mq-pci.c ?

Not really. We can lose these from blk-mq-pci.c as well.

>> +#include <linux/blk-mq.h>
>> +#include <linux/blk-mq-rdma.h>
>> +#include <rdma/ib_verbs.h>
>> +#include <linux/module.h>
>> +#include "blk-mq.h"
>
> Is this include needed ?

You're right, I can just keep:

+#include <linux/blk-mq.h>
+#include <linux/blk-mq-rdma.h>
+#include <rdma/ib_verbs.h>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
