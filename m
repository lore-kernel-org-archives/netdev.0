From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out
 to <linux/radix-tree-root.h>
Date: Tue, 10 Oct 2017 06:20:25 -0700
Message-ID: <20171010132025.GA2687@bombadil.infradead.org>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <20171010121829.GA26493@bombadil.infradead.org>
 <CAK7LNAQ_SVA1aYYgjMFqJG5OzjYa1EbNDGdrCAOOen_dABX30g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-cachefs@redhat.com, linux-sh@vger.kernel.org,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        David Airlie <airlied@linux.ie>, linux-rdma@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rich Felker <dalias@libc.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        intel-gfx@lists.freedesktop.org,
        Yishai
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK7LNAQ_SVA1aYYgjMFqJG5OzjYa1EbNDGdrCAOOen_dABX30g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 09:56:22PM +0900, Masahiro Yamada wrote:
> One refactoring alone does not produce much benefits,
> but making continuous efforts will disentangle the knotted threads.
> Of course, this might be a pipe dream...

A lot of people have had that dream, and some of those refactoring
efforts have proven worthwhile.  But it's not a dream without costs;
your refactoring will conflict with other changes.  I don't think the
benefit here is high enough to pursue this edition of the dream.
