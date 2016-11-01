From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for
 forwarded ICMP errors from offending packet
Date: Tue, 01 Nov 2016 12:39:04 -0400 (EDT)
Message-ID: <20161101.123904.1432761986039949225.davem@davemloft.net>
References: <87bmxznsgg.fsf@redhat.com>
        <20161101.113505.1429989348222226550.davem@davemloft.net>
        <7f83a405-0520-a3ed-fc21-402d702483f9@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkbs@redhat.com, tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7f83a405-0520-a3ed-fc21-402d702483f9@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 1 Nov 2016 17:27:56 +0100

> On 01.11.2016 16:35, David Miller wrote:
>> I have a really hard time accepting a "fix" that depends upon behavior
>> that the Linux ipv6 stack doesn't even have.
> 
> We actually support this feature:

But it is forbidden when the sysctl I mentioned is set, which is the
default.

I'm talking about default behavior, which is to not reflect.
