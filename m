From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [PATCH] net: pegasus: Remove deprecated create_singlethread_workqueue
Date: Wed, 31 Aug 2016 17:27:51 +0300
Message-ID: <E774CB24-BD0A-41AE-B414-FBC8BFD5447E@mip-labs.com>
References: <20160830163247.GA25925@Karyakshetra> <20160831142305.GI12660@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Petko Manolov <petkan@nucleusys.com>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831142305.GI12660@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 31, 2016 5:23:05 PM GMT+03:00, Tejun Heo <tj@kernel.org> wrote:
>On Tue, Aug 30, 2016 at 10:02:47PM +0530, Bhaktipriya Shridhar wrote:
>> The workqueue "pegasus_workqueue" queues a single work item per
>pegasus
>> instance and hence it doesn't require execution ordering. Hence,
>> alloc_workqueue has been used to replace the deprecated
>> create_singlethread_workqueue instance.
>> 
>> The WQ_MEM_RECLAIM flag has been set to ensure forward progress under
>> memory pressure since it's a network driver.
>> 
>> Since there are fixed number of work items, explicit concurrency
>> limit is unnecessary here.
>> 
>> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
>
>Acked-by: Tejun Heo <tj@kernel.org>
>
>Thanks.


Acked-by: Petko Manolov <petkan@mip-labs.com>


cheers,
Petko
