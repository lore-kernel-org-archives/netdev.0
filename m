From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 08:27:03 +0200
Message-ID: <20161013062703.GC310@x4>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net>
 <20161013060206.GA310@x4>
 <20161013060659.GB310@x4>
 <CA+55aFwsUR4-YmOYgJOOO4a2e48M4_tk7YhAo4s5KZQQxUjpZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>, Jens Axboe <axboe@fb.com>,
        linux-kernel@vger.kernel.org, aconole@redhat.com,
        David Miller <davem@davemloft.net>, pablo@netfilter.org,
        linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        akpm@linux-foundation.org, fw@strlen.de, tytso@mit.edu
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:56827 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934338AbcJMG1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 02:27:07 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFwsUR4-YmOYgJOOO4a2e48M4_tk7YhAo4s5KZQQxUjpZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016.10.12 at 23:18 -0700, Linus Torvalds wrote:
> On Oct 12, 2016 23:07, "Markus Trippelsdorf" <markus@trippelsdorf.de> wrote:
> >
> > This is nf_register_net_hook at net/netfilter/core.c:106
>
> The "*regs" access?

Yeah.

105         entry->orig_ops = reg;
106         entry->ops      = *reg;
107         entry->next     = NULL;
