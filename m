From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] netfilter: nf_conntrack: remove the unneed check
 for *bucket
Date: Sun, 31 Jan 2016 11:37:07 +0800
Message-ID: <56AD8163.4050309@huawei.com>
References: <56ACABBC.9050303@huawei.com> <20160130213003.GA13560@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, David Miller <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160130213003.GA13560@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/1/31 5:30, Florian Westphal wrote:
> Weidong Wang <wangweidong1@huawei.com> wrote:
>> In the 'for(...) {}', the *bucket alwasy < net->ct.htable_size,
>> so remove the check
>> @@ -1383,14 +1383,12 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
>>  		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
>>  		local_bh_disable();
>>  		spin_lock(lockp);
>> -		if (*bucket < net->ct.htable_size) {
> 
> AFAIU net->ct.htable_size can shrink between for-test and aquiring
> the bucket lockp, so this additional if-test is needed.
> 

ok, Got it.
So ignore this patch.

Regards,
Weidong

> .
> 
