From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2 nf-next] netfilter: seqadj: print the warning log
 when fail to add seqadj extension
Date: Fri, 2 Sep 2016 08:54:45 +0200
Message-ID: <20160902065445.GB8883@breakpoint.cc>
References: <1472781036-13547-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472781036-13547-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fgao@ikuai8.com <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Print the warning log when fail to add seqadj extension like
> nf_ct_acct_ext_add does. It could be helpful to find the problem.

Failure to add ext area means that we're pretty much completely out
of memory.  There is nothing the user could do, so pr_warn (or any other
log level ...) is not really helpful.

Besides, memory subsystem will already print diagnostic information in
that case.

