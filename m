From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Patch v2] mqueue: fix a use-after-free in sys_mq_notify()
Date: Sun, 9 Jul 2017 14:37:48 -0700
Message-ID: <CA+55aFz=RecjG8PYT_DyT99HpPKFaK9CGX2WA+FZDRm=95uNug@mail.gmail.com>
References: <1499631595-12625-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Gene Blue <geneblue.mail@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499631595-12625-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 9, 2017 at 1:19 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Setting 'sock' to NULL here should be sufficient to fix it.

Thanks. Applied and marked for stable.

                 Linus
