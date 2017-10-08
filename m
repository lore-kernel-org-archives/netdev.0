From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with
 <linux/radix-tree-root.h>
Date: Sun, 08 Oct 2017 10:32:22 -0700
Message-ID: <1507483942.11434.4.camel@perches.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
         <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
         <20171008.100013.2081721941420989813.davem@davemloft.net>
         <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>, abbotti@mev.co.uk,
        Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-rdma@vger.kernel.org, yishaih@mellanox.com,
        tariqt@mellanox.com, netdev@vger.kernel.org
To: Masahiro Yamada <yamada.masahiro@socionext.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-09 at 02:29 +0900, Masahiro Yamada wrote:
> The idea is simple; include necessary headers explicitly.

Try that for kernel.h

There's a reason aggregation of #includes is useful.
