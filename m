From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] tipc: remove two indentation
 levels in tipc_recv_msg routine
Date: Wed, 30 Oct 2013 09:34:57 +0800
Message-ID: <52706241.60600@windriver.com>
References: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com>
	<20131029120708.GI14038@eerihug-hybrid.rnd.ki.sw.ericsson.se>
	<526FACA9.9020004@ericsson.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73BD@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net,
	Paul.Gortmaker@windriver.com
To: David Laight <David.Laight@ACULAB.COM>, =?windows-1252?Q?Andreas_Bo?=
	=?windows-1252?Q?fj=E4ll?= <andreas.bofjall@ericsson.com>, Erik Hugne
	<erik.hugne@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73BD@saturn3.aculab.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10/29/2013 08:42 PM, David Laight wrote:
>>   		continue;
>> +
>> +unlock:
>> +		tipc_node_unlock(n_ptr);
>>   cont:
>>   		kfree_skb(buf);
>>   	}
> 
> Might be better to call the labels 'unlock_discard' and 'discard'.
> 

Thanks for your valuable suggestions. I will submit next version soon.

Regards,
Ying

> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
