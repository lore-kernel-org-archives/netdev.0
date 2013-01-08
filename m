From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: NULL dereference on error in debug code
Date: Tue, 08 Jan 2013 14:30:58 -0800 (PST)
Message-ID: <20130108.143058.802178708339067441.davem@davemloft.net>
References: <20130108134213.GA23742@elgon.mountain>
	<6AE768456CEC4B4A9B2248CB6B87EB3E1BCC7E9F@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, eilong@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: ariele@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BCC7E9F@SJEXCHMB05.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ariel Elior" <ariele@broadcom.com>
Date: Tue, 8 Jan 2013 14:50:50 +0000

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Dan Carpenter
>> Sent: Tuesday, January 08, 2013 3:42 PM
>> To: Eilon Greenstein
>> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; kernel-
>> janitors@vger.kernel.org
>> Subject: [patch] bnx2x: NULL dereference on error in debug code
>> 
>> "vfop" is NULL here.  I've changed the debugging to not use it.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> Only needed in linux-next.
>> 
>> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> index 71fcef0..3eef972 100644
>> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> @@ -463,8 +463,7 @@ static int bnx2x_vfop_qdtor_cmd(struct bnx2x *bp,
>>  		return bnx2x_vfop_transition(bp, vf, bnx2x_vfop_qdtor,
>>  					     cmd->block);
>>  	}
>> -	DP(BNX2X_MSG_IOV, "VF[%d] failed to add a vfop. rc %d\n",
>> -	   vf->abs_vfid, vfop->rc);
>> +	DP(BNX2X_MSG_IOV, "VF[%d] failed to add a vfop.\n", vf->abs_vfid);
>>  	return -ENOMEM;
>>  }
>> 
> Right you are. Ack.

This is not the correct way to ack a patch, this is:

Acked-by: Ariel Elior <ariele@broadcom.com>
