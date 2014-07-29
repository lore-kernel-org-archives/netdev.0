From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 1/2] netfilter: xt_bpf: don't include
 linux/filter.h from uapi header
Date: Tue, 29 Jul 2014 18:05:49 +0200
Message-ID: <20140729160549.GA4546@salvia>
References: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
 <CA+FuTSdRmnFYK1mTFh14UP1rTkU-EYK-61xyoWWiNvZR3Aig6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>, keescook@chromium.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+FuTSdRmnFYK1mTFh14UP1rTkU-EYK-61xyoWWiNvZR3Aig6A@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2014 at 11:43:57AM -0400, Willem de Bruijn wrote:
> > In e6f30c7 ("netfilter: x_tables: add xt_bpf match"), the internal
> > linux/filter.h header slipped through in the user exposed xt_bpf.h
> > header as included file.
> 
> is that true? #include <linux/filter.h> should include
> include/uapi/linux/filter.h in userspace builds.

You're right. I'm going to send a v2.

We should also cache the linux/filter.h header in the iptables
sources, would you send a patch for that? Thanks.
