From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy
Date: Thu, 23 Jan 2014 21:49:11 +0000
Message-ID: <52E18E57.8040600@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	<20140122.175031.873909526743971037.davem@davemloft.net>	<52E11563.1090707@citrix.com> <20140123.133948.1912867106975845377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140123.133948.1912867106975845377.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/01/14 21:39, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Thu, 23 Jan 2014 13:13:07 +0000
>
>> It is already based on two predecessor patches, one which is already
>> accepted but not applied yet:
>>
>> [PATCH net-next v2] xen-netback: Rework rx_work_todo
>>
>> And the other one is hopefully will be accepted very soon:
>>
>> [PATCH v5] xen/grant-table: Avoid m2p_override during mapping
>
> These have both been asked for changes or small adjustments to be made.
AFAIK Wei acked the netback one:

http://www.spinics.net/lists/netdev/msg267800.html

I've just sent in the latest one for the grant mapping one

> Also, you really have to precisely and explicitly mention any
> dependencies which exist.
Ok, the grant mapping API dependency is vaguely mentioned in the patch 
history, I'll move it. I haven't mentioned the other one because it's 
not related to the grant mapping changes, it's a generic bug.

> In fact, it's often best to not post a series until the dependent
> patches have been accepted.
I've posted the first version of this series in November, these two 
issues turned up in the recent weeks.

Zoli
