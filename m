From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 16:02:27 -0800
Message-ID: <AANLkTim71374Qb1TW5Lc8H+rpQNk5a25ARczHU-+cn=D@mail.gmail.com>
References: <20110119.180418.216749267.davem@davemloft.net>
 <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
 <1295559646.2613.35.camel@edumazet-laptop> <AANLkTikLY1B3=C2TjAbYKVHbub-aPeG2heaUBWRUAg=R@mail.gmail.com>
 <AANLkTin6GM5W0nmWgD1a-2FK=CvHk=P3o6CYe-sFe6c=@mail.gmail.com> <AANLkTin-RBwg+J4MqOm7A40-TFAJ1sp4e6tzi6OaobNi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Walters <walters@verbum.org>,
	Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTin-RBwg+J4MqOm7A40-TFAJ1sp4e6tzi6OaobNi@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2011 at 3:43 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> But it turns out to be a kernel bug after all, although not in
> networking. It bisected down to commit e462c448fdc8: "pipe: use event
> aware wakeups".
>
> Anyway, I'll double-check my bisect by doing a revert of that commit
> on top of current -git, but I'm pretty sure the bisect was correct,
> since it did end up pointing to a commit that clearly changed poll
> behavior.

Confirmed. With that commit reverted, gnome-screensaver-dialog works again.

So far I only did a revert, I didn't see exactly _which_ of the wakeup
cases it was. But it's definitely that commit.

                       Linus
