From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] Networking
Date: Fri, 22 Aug 2014 14:32:58 -0700
Message-ID: <CA+55aFxsf02Lt+rFOxf0rXu1WoqZW0omGzwdHUfSfo+O9EqUAw@mail.gmail.com>
References: <20140822.114711.856705392345846995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140822.114711.856705392345846995.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2014 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
>
> Here are some bug fixes that have piled up during ksummit/linuxcon.

Hmm. What happened to the patch titled "mac80211: fix channel switch
for chanctx-based drivers" by Michal Kazior?

That one fixes a rather nasty oops that results in dead machines. It's
generic wireless code, but hits with at least intel wireless cards. It
needs the AP to send a channel switch request, but if that happens
(and it does), the kernel goes belly-up.

            Linus
