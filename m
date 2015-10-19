From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [RFC PATCH] RDS: convert bind hash table to re-sizable hashtable
Date: Mon, 19 Oct 2015 09:45:37 -0700
Message-ID: <56251E31.8040704@oracle.com>
References: <1444857331-4344-1-git-send-email-santosh.shilimkar@oracle.com>
 <20151018.185624.521387334647995840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151018.185624.521387334647995840.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18/2015 6:56 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Wed, 14 Oct 2015 14:15:31 -0700
>
>> From: Santosh Shilimkar <ssantosh@kernel.org>
>>
>> To further improve the RDS connection scalabilty on massive systems
>> where number of sockets grows into tens of thousands  of sockets, there
>> is a need of larger bind hashtable. Pre-allocated 8K or 16K table is
>> not very flexible in terms of memory utilisation. The rhashtable
>> infrastructure gives us the flexibility to grow the hashtbable based
>> on use and also comes up with inbuilt efficient bucket(chain) handling.
>>
>> Cc: David Laight <David.Laight@ACULAB.COM>
>> Cc: David Miller <davem@davemloft.net>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>
> This looks fine as far as I can tell.


Thanks for review Dave !!

Regards,
Santosh
