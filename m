From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] RDS: IB: NULL dereference on error in rds_ib_alloc_frmr()
Date: Wed, 14 Jun 2017 10:18:25 -0700
Message-ID: <eecbb80f-9df3-e717-7af2-4407a3a40d3c@oracle.com>
References: <20170614103924.GK29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Avinash Repaka <avinash.repaka@oracle.com>,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        kernel-janitors@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28722 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdFNRS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:18:29 -0400
In-Reply-To: <20170614103924.GK29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/17 3:39 AM, Dan Carpenter wrote:
> We accidentally return ERR_PTR(0) if ib_alloc_mr() fails.  The caller
> is expecting error pointers so it results in a NULL dereference.
>
> Fixes: 1659185fb4d0 ("RDS: IB: Support Fastreg MR (FRMR) memory registration mode")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
Thanks Dan for fix.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

You haven't copied netdev. Can you please resend the patch
with my ack on netdev so that Dave can pick it up.
