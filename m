From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH 02/18] RDS: mark few internal functions static
 to make sparse build happy
Date: Mon, 5 Dec 2016 17:17:50 -0800
Message-ID: <52e13934-1e59-4166-9ccf-7bfe769d7219@oracle.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
 <1480921073-9140-3-git-send-email-santosh.shilimkar@oracle.com>
 <604d4954-7302-018e-6f9b-71c0aea6509e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <604d4954-7302-018e-6f9b-71c0aea6509e@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/5/2016 1:45 AM, Sergei Shtylyov wrote:
> Hello!
>
> On 12/5/2016 9:57 AM, Santosh Shilimkar wrote:
>
[...]

>> -void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
>> +static void rds_walk_conn_path_info(struct socket *sock, unsigned int
>> len,
>>                   struct rds_info_iterator *iter,
>>                   struct rds_info_lengths *lens,
>>                   int (*visitor)(struct rds_conn_path *, void *),
>
>    You now need to realign the continuation lines.
>
Right. Will fix that. Thanks !!

Regards,
Santosh
