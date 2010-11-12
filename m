From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 14:28:31 +0800
Message-ID: <20101112062831.GA5660@cr0.nay.redhat.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
 <1289489007.17691.1310.camel@edumazet-laptop>
 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>>
>> Is TILE using ticket spinlocks ?
>>

Eric, yes.


>
>What ticket spinlocks means? Could you explain a little, pls:) I'm not
>familiar with Linux kernel, I'm trying to get more understanding of it
>since I'm working on Linux platform now.
>

You might want to search "ticket spinlock" with google. :)

Briefly speaking, it is introduced to solve unfairness
of the old spinlock implementation. In linux kernel, not all
arch implement this. X86 implementation is done by Nick with
asm code, while tile uses C to implement it.
