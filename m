From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: remove BUG_ONs from net_generic()
Date: Fri, 17 Apr 2015 15:22:00 -0400 (EDT)
Message-ID: <20150417.152200.405809009304639029.davem@davemloft.net>
References: <1429290390-5600-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429290390-5600-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Fri, 17 Apr 2015 19:06:30 +0200

> This inline has ~500 callsites.
> 
> On 04/14/2015 08:37 PM, David Miller wrote:
>> That BUG_ON() was added 7 years ago, and I don't remember it ever
>> triggering or helping us diagnose something, so just remove it and
>> keep the function inlined.
> 
> On x86 allyesconfig build:
> 
>     text     data      bss       dec     hex filename
> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
> 82441375 22255384 20627456 125324215 7784bb7 vmlinux5prime
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Applied.
