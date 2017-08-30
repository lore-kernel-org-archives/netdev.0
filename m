From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] RDS: constify rhashtable_params
Date: Wed, 30 Aug 2017 06:54:43 -0700
Message-ID: <c8f861c1-b137-740d-78fe-e03e8232af09@oracle.com>
References: <3cdaecc7c8080b0f2172d8788b96303528957b08.1504093495.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43623 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdH3Nyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 09:54:55 -0400
In-Reply-To: <3cdaecc7c8080b0f2172d8788b96303528957b08.1504093495.git.arvind.yadav.cs@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/17 4:49 AM, Arvind Yadav wrote:
> rhashtable_params are not supposed to change at runtime. All
> Functions rhashtable_* working with const rhashtable_params
> provided by <linux/rhashtable.h>. So mark the non-const structs
> as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
This is already addressed in net-next by [1]

Regards,
Santosh

[1] https://lkml.org/lkml/2017/8/25/482
