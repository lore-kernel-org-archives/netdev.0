From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH] Deinline __nlmsg_put and genlmsg_put. -7k code on i386
 defconfig
Date: Mon, 30 Jan 2012 20:37:00 +0100
Message-ID: <4F26F15C.9080808@redhat.com>
References: <4F2597D3.6050606@redhat.com> <20120130.131104.1782962680660646529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130.131104.1782962680660646529.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 07:11 PM, David Miller wrote:
> This doesn't apply to net-next, it appears it was corrupted by your
> email client:
>
>> -static __inline__ struct nlmsghdr *
>> -__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len,
>> -int flags)
>
> It appears to have chopped up a long line here, for example.

I rediffed the patch against net-next, compile-tested it and going
to send it using git-send-email in a minute.

-- 
vda
