From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 04:41:57 -0400 (EDT)
Message-ID: <20120418.044157.1410691335536408716.davem@davemloft.net>
References: <20120417085248.3e642294@nehalam.linuxnetplumber.net>
	<1334681323.2472.43.camel@edumazet-glaptop>
	<4F8E73E3.6080900@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ctrix+debianbugs@navynet.it, peter.huangpeng@gmail.com,
	harry.majun@huawei.com
To: peter.huangpeng@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F8E73E3.6080900@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Date: Wed, 18 Apr 2012 15:57:23 +0800

> On 2012/4/18 0:48, Eric Dumazet wrote:
>> On Tue, 2012-04-17 at 08:52 -0700, Stephen Hemminger wrote:
>>
>>> This check seems like a disaster waiting to happen when the next
>>> change to DST table happens.
>>
>> Please Peter Document this, adding a new DST_FAKE_RTABLE flag
>>
>> #define DST_FAKE_RTABLE DST_NOPEER
>>
>> or just use a bit, we have plenty of them available.
>>
> 
> 
> Add DST_FAKE_RTABLE to dst_entry, this is the new patch.
> Is this ok?
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>

Please post new patches as completely new emails, not as replies
to other emails.
