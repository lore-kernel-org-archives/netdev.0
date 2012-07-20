From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] sunrpc: clnt: Add missing braces
Date: Fri, 20 Jul 2012 17:25:27 +0000
Message-ID: <B303B8C0-4BB4-4900-84F4-457E9CF291D7@netapp.com>
References: <1342635431.9551.41.camel@joe2Laptop>
 <1342803059.21447.45.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"Chuck Lever" <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1342803059.21447.45.camel@joe2Laptop>
Content-Language: en-US
Content-ID: <7EE93B58910E5246999176117BEB63F0-oP88Kt8RkgzdA/Lu/QRl1Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

No. It should go through the NFS client tree.

I can queue it up.


--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

On Jul 20, 2012, at 6:50 PM, Joe Perches wrote:

> On Wed, 2012-07-18 at 11:17 -0700, Joe Perches wrote:
>> Add a missing set of braces that commit 4e0038b6b24
>> ("SUNRPC: Move clnt->cl_server into struct rpc_xprt")
>> forgot.
>> 
>> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>> ---
>> net/sunrpc/clnt.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index f56f045..aaf70aa 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1844,12 +1844,13 @@ call_timeout(struct rpc_task *task)
>> 		return;
>> 	}
>> 	if (RPC_IS_SOFT(task)) {
>> -		if (clnt->cl_chatty)
>> +		if (clnt->cl_chatty) {
>> 			rcu_read_lock();
>> 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
>> 				clnt->cl_protname,
>> 				rcu_dereference(clnt->cl_xprt)->servername);
>> 			rcu_read_unlock();
>> +		}
>> 		if (task->tk_flags & RPC_TASK_TIMEOUT)
>> 			rpc_exit(task, -ETIMEDOUT);
>> 		else
> 
> Hi David.
> 
> I think it'd be good to get this into 3.6 as a bug fix.
> 
> This is marked in netdev patchwork as "not applicable".
> 
> Do you need the sunrpc maintainers to apply or ack it
> and then push it to you?
> 
> Trond?  Bruce?
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
