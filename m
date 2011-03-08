From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH] drivers/net: fix build warnings with CONFIG_PM_SLEEP disabled
Date: Mon, 7 Mar 2011 16:02:30 -0800
Message-ID: <AANLkTi=+XXypyyOkGmAnuX+3Hsw50yOrqo9j6bX6LCRH@mail.gmail.com>
References: <20110307021450.GC31188@google.com>
	<20110307150735.3d6515f2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110307150735.3d6515f2@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 7, 2011 at 3:07 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Sun, 6 Mar 2011 18:14:50 -0800
> Michel Lespinasse <walken@google.com> wrote:
>
>> This fixes a couple of build warnings when CONFIG_PM is enabled but
>> CONFIG_PM_SLEEP is disabled. Applies on top of v2.6.38-rc7 - I know it's
>> late, but it would be great if v2.6.38 could compile without warnings!
>>
>> Signed-off-by: Michel Lespinasse <walken@google.com>
>
> This is standard throughout all the network drivers.
> Why just fix 2?

I only looked at the build warnings we get with our local config.
Some drivers do get this right, such as tg3 for example.

Having a quick look at other SIMPLE_DEV_PM_OPS users, it seems at
least drivers/net/skge.c does have the same issue though.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
