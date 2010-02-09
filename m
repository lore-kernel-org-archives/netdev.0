From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 11/13] net: irda: use seq_list_foo() helpers
Date: Tue, 09 Feb 2010 14:57:58 +0800
Message-ID: <4B710776.9020800@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com> <4B6B78AD.1030809@cn.fujitsu.com> <4B6C051F.3080702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6C051F.3080702@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paulius Zaleckas wrote:
> On 02/05/2010 03:47 AM, Li Zefan wrote:
> [...]
>>   /* Return entry after v, and increment pos */
>> @@ -1148,14 +1137,7 @@ static void *irlan_seq_next(struct seq_file
>> *seq, void *v, loff_t *pos)
>>   {
>>       struct list_head *nxt;
> 
> you should remove nxt declaration.
> 

Thanks! Will fix.
