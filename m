From: Alexei Starovoitov <ast@fb.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 23 Mar 2017 18:24:11 -0700
Message-ID: <9414bc03-4b88-83e3-0cd7-9c227b756da9@fb.com>
References: <20170324110514.0376c46f@canb.auug.org.au>
 <20170323.171035.27948034948873194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-next@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kafai@fb.com>
To: David Miller <davem@davemloft.net>, <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323.171035.27948034948873194.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/23/17 5:10 PM, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 24 Mar 2017 11:05:14 +1100
>
>> Hi all,
>>
>> Today's linux-next merge of the net-next tree got a conflict in:
>>
>>   kernel/bpf/hashtab.c
>>
>> between commit:
>>
>>   8c290e60fa2a ("bpf: fix hashmap extra_elems logic")
>>
>> from Linus' tree and commit:
>>
>>   bcc6b1b7ebf8 ("bpf: Add hash of maps support")
>>
>> from the net-next tree.
>>
>> I fixed it up (see below) and can carry the fix as necessary. This
>> is now fixed as far as linux-next is concerned, but any non trivial
>> conflicts should be mentioned to your upstream maintainer when your tree
>> is submitted for merging.  You may also want to consider cooperating
>> with the maintainer of the conflicting tree to minimise any particularly
>> complex conflicts.
>
> I did the same resolution just an hour ago when merging net into
> net-next.

yes. that's correct merge conflict resolution.
Just rebuilt and retested. All looks good.
Thanks!
