From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: missing parentheses
Date: Thu, 16 Apr 2009 16:03:38 -0700 (PDT)
Message-ID: <20090416.160338.35558187.davem@davemloft.net>
References: <49E79D7C.2080200@gmail.com>
	<20090416141610.ad8b9909.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	roel.kluin@gmail.com, jeffrey.t.kirsher@intel.com
To: akpm@linux-foundation.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090416141610.ad8b9909.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 16 Apr 2009 14:16:10 -0700

>> @@ -3946,7 +3946,7 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
>>  	}
>>  	hw->mac.ops.setup_sfp(hw);
>>  
>> -	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
>> +	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
>>  		/* This will also work for DA Twinax connections */
>>  		schedule_work(&adapter->multispeed_fiber_task);
>>  	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;
> 
> This is fixed in linux-next, but hasn't been pushed to Linus yet.

If I recall correctly, this got submitted to me as a net-next-2.6 only
patch, which obviously isn't correct.

Intel folks, please resubmit this to me for net-2.6 too, thanks.

------------------------------------------------------------------------------
Stay on top of everything new and different, both inside and 
around Java (TM) technology - register by April 22, and save
$200 on the JavaOne (SM) conference, June 2-5, 2009, San Francisco.
300 plus technical and hands-on sessions. Register today. 
Use priority code J9JMT32. http://p.sf.net/sfu/p
