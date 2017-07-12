From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Thu, 13 Jul 2017 00:19:35 +0200
Message-ID: <20170712221935.GC12347@breakpoint.cc>
References: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
 <20170630193544.GM9307@breakpoint.cc>
 <f3d78dc5-7694-8e01-ac4d-54fc248a96f1@nod.at>
 <20170630195547.GN9307@breakpoint.cc>
 <ad87cf0f-2ff4-48d7-b53c-bc4b5e98cfca@nod.at>
 <20170701103504.GO9307@breakpoint.cc>
 <1daf1401-5009-df1c-a77a-a271811c0760@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1daf1401-5009-df1c-a77a-a271811c0760@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> wrote:
> Am 01.07.2017 um 12:35 schrieb Florian Westphal:
> > The compare on removal is not needed afaics, and its also not used when
> > doing lookup to begin with, so we can just recompute it?
> 
> Isn't this a way too much overhead?

I don't think so.  This computation only occurs when we dump events
to userspace.

> I personally favor Pablo's per-cpu counter approach.
> That way the IDs are unique again and we get rid of the info leak without
> much effort.

I have not seen these patches so can't really comment.
