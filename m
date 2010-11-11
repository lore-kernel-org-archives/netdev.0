From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Simplify rpc_alloc_iostats by removing pointless local variable
Date: Thu, 11 Nov 2010 10:57:47 -0500
Message-ID: <1745E543-5867-4814-9678-5E73AD2C25BA@oracle.com>
References: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net> <alpine.LNX.2.00.1011102229370.625@swampdragon.chaosbits.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1011102229370.625-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Nov 10, 2010, at 4:32 PM, Jesper Juhl wrote:

> On Sun, 7 Nov 2010, Jesper Juhl wrote:
> 
>> Hi,
>> 
>> We can simplify net/sunrpc/stats.c::rpc_alloc_iostats() a bit by getting 
>> rid of the unneeded local variable 'new'.
>> 
>> 
>> Please CC me on replies.
>> 
>> 
>> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
>> ---
>> stats.c |    4 +---
>> 1 file changed, 1 insertion(+), 3 deletions(-)
>> 
>> diff --git 
>> a/net/sunrpc/stats.c b/net/sunrpc/stats.c
>> index f71a731..80df89d 100644
>> --- a/net/sunrpc/stats.c
>> +++ b/net/sunrpc/stats.c
>> @@ -115,9 +115,7 @@ EXPORT_SYMBOL_GPL(svc_seq_show);
>>  */
>> struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt)
>> {
>> -	struct rpc_iostats *new;
>> -	new = kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
>> -	return new;
>> +	return kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
>> }
>> EXPORT_SYMBOL_GPL(rpc_alloc_iostats);
>> 
>> 
>> 
> 
> Ok, no response to this for a couple of days.
> Is there some problem or did it just get missed?
> Could someone merge this and push it up-stream, please, if there are no 
> problems with it...

The NFS maintainer is traveling.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
