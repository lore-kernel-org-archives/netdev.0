From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V7 2/4 net-next] skbuff: Add userspace zero-copy
 buffers in skb
Date: Tue, 28 Jun 2011 16:35:08 -0700 (PDT)
Message-ID: <20110628.163508.222352070705159851.davem@davemloft.net>
References: <1309189510.21764.1.camel@localhost.localdomain>
	<20110627.155426.51839633424542723.davem@davemloft.net>
	<1309279892.3559.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, avi@redhat.com,
	arnd@arndb.de, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1309279892.3559.6.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>
Date: Tue, 28 Jun 2011 09:51:32 -0700

> On Mon, 2011-06-27 at 15:54 -0700, David Miller wrote:
>> From: Shirley Ma <mashirle@us.ibm.com>
>> Date: Mon, 27 Jun 2011 08:45:10 -0700
>> 
>> > To support skb zero-copy, a pointer is needed to add to skb share
>> info.
>> > Do you agree with this approach? If not, do you have any other
>> > suggestions?
>> 
>> I really can't form an opinion unless I am shown the complete
>> implementation, what this give us in return, what the impact is, etc. 
 ..
> You can see the overall CPU saved 50% w/i zero-copy.
> 
> The impact is every skb allocation consumed one more pointer in skb
> share info, and a pointer check in skb release when last reference is
> gone.
> 
> For skb clone, skb expand private head and skb copy, it still keeps copy
> the buffers to kernel, so we can avoid user application, like tcpdump to
> hold the user-space buffers too long.

Ok, now show me the "complete implementation".  I'm as interested in
the code as I am in the numbers, that's why I asked for both.
