From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 01:23:58 -0400 (EDT)
Message-ID: <20130502.012358.544724724472994582.davem@davemloft.net>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
	<CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 May 2013 18:28:38 -0700

> On Wed, May 1, 2013 at 1:47 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Highlights (1721 non-merge commits, this has to be a record of some
>> sort):
> 
> Lowlight: it completely breaks my machine with r8169 ethernet.  In the
> networkmanager applet, it claims no cable connection, which is a bit
> odd, because (a) it works with an older kernel and (b) the kernel
> messages actually say
> 
>   r8169 0000:01:00.0 eth0: link up
> 
> but nothing actually works.
> 
>  r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>  r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xffffc90010ece000,
> e0:cb:4e:95:1a:d7, XID 083000c0 IRQ 53
>  r8169 0000:01:00.0 eth0: jumbo features [frames: 9200 bytes, tx
> checksumming: ko]
> 
> Any ideas?

I'll take a look at this first thing tomorrow if someone doesn't beat
me to it.
