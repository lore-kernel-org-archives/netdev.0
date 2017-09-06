From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] rds: Fix incorrect statistics counting
Date: Wed, 6 Sep 2017 09:21:01 -0700
Message-ID: <6fb62a09-13b4-0cec-2864-40afdfc51d25@oracle.com>
References: <20170906152950.17766-1-Haakon.Bugge@oracle.com>
 <b620a15a-e60e-5c35-ffef-ee485d338774@oracle.com>
 <715EA84D-6ACA-45DE-9EA2-6122E11545E8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        OFED mailing list <linux-rdma@vger.kernel.org>,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        Knut Omang <knut.omang@oracle.com>
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <haakon.bugge@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <715EA84D-6ACA-45DE-9EA2-6122E11545E8@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/6/2017 9:12 AM, Håkon Bugge wrote:
> 
[...]

> 
> Hi Santosh,
> 
> 
> Yes, I agree with accuracy of s_send_lock_queue_raced. But the main point is that the existing code counts some partial share of when it is _not_ raced.
> 
> So, in the critical path, my patch adds one test_bit(), which hits the local CPU cache, if not raced. If raced, some other thread is in control, so I would not think the added cycles would make any big difference.
>
Cycles added for no good reason is the point.

> I can send a v2 where the race tightening is removed if you like.
> 
Yes please.

Regards,
Santosh
