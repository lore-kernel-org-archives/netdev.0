From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Fri, 30 Jun 2017 21:35:44 +0200
Message-ID: <20170630193544.GM9307@breakpoint.cc>
References: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>, fw@strlen.de,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> wrote:
> Hi!
> 
> I noticed that nf_conntrack leaks kernel addresses, it uses the memory address
> as identifier used for generating conntrack and expect ids..
> Since these ids are also visible to unprivileged users via network namespaces
> I suggest reverting these commits:

Why not use a hash of the address?
