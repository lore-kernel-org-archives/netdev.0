From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 5/8] i40e: Fix TSO and hw checksums for
 non-accelerated vlan packets.
Date: Sat, 23 Aug 2014 21:13:52 -0400
Message-ID: <53F93C50.9070609@gmail.com>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>	<1408760230-7457-6-git-send-email-vysevich@gmail.com>
	<20140823.114357.1040666365885664477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com, john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140823.114357.1040666365885664477.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08/23/2014 02:43 PM, David Miller wrote:
> From: vyasevich@gmail.com
> Date: Fri, 22 Aug 2014 22:17:07 -0400
> 
>> @@ -2295,7 +2295,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
>>  		goto out_drop;
>>  
>>  	/* obtain protocol of skb */
>> -	protocol = skb->protocol;
>> +	protocol = get_vlan_protocol(skb);
> 
> I don't think this even compiles.
> 
> It's "vlan_get_protocol" not "get_vlan_protocol".
> 

Yes.  I notice this one as well this morning, but didn't have time to fix.

Apologies.

-vlad

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
