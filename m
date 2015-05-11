From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Mon, 11 May 2015 10:41:21 -0400 (EDT)
Message-ID: <20150511.104121.111988027007099988.davem@davemloft.net>
References: <1431317294-16442-1-git-send-email-kys@microsoft.com>
	<1431323894.2884.4.camel@perches.com>
	<BY2PR0301MB0711C1248DF6677217A310BCA0DB0@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB0711C1248DF6677217A310BCA0DB0@BY2PR0301MB0711.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KY Srinivasan <kys@microsoft.com>
Date: Mon, 11 May 2015 08:59:53 +0000

> 
> 
>> -----Original Message-----
>> From: Joe Perches [mailto:joe@perches.com]
>> Sent: Sunday, May 10, 2015 10:58 PM
>> To: KY Srinivasan
>> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
>> apw@canonical.com; jasowang@redhat.com
>> Subject: Re: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to
>> optimize signaling the host
>> 
>> On Sun, 2015-05-10 at 21:08 -0700, K. Y. Srinivasan wrote:
>> > Based on the information given to this driver (via the xmit_more skb flag),
>> > we can defer signaling the host if more packets are on the way. This will
>> help
>> > make the host more efficient since it can potentially process a larger batch
>> of
>> > packets. Implement this optimization.
>> 
>> trivia:
>> 
>> I think that indirecting
>> VMBUS_DATA_PACKET_FLAG_COMPLETTION_REQUESTED
>> into a non-const temporary isn't very useful.
>> 
>> Whenever overly long identifiers like VMBUS_<FOO> is used,
>> I think that it'd be better to use it directly and ignore
>> 80 column warnings.
> 
> Thanks Joe; if Dave agrees, I can send v6 of this patch out.

Sure, respin a v6.
