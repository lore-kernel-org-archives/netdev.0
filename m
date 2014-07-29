From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 1/2] netfilter: xt_bpf: don't include
 linux/filter.h from uapi header
Date: Tue, 29 Jul 2014 19:03:00 +0200
Message-ID: <20140729170300.GA6216@salvia>
References: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
 <CA+FuTSdRmnFYK1mTFh14UP1rTkU-EYK-61xyoWWiNvZR3Aig6A@mail.gmail.com>
 <20140729160549.GA4546@salvia>
 <CA+FuTSfJWjEBADJi9vPat062WYx-TtX5_XtzNZziFtPfe=0oHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Kees Cook <keescook@chromium.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+FuTSfJWjEBADJi9vPat062WYx-TtX5_XtzNZziFtPfe=0oHg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2014 at 12:35:00PM -0400, Willem de Bruijn wrote:
> On Tue, Jul 29, 2014 at 12:05 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Tue, Jul 29, 2014 at 11:43:57AM -0400, Willem de Bruijn wrote:
> >> > In e6f30c7 ("netfilter: x_tables: add xt_bpf match"), the internal
> >> > linux/filter.h header slipped through in the user exposed xt_bpf.h
> >> > header as included file.
> >>
> >> is that true? #include <linux/filter.h> should include
> >> include/uapi/linux/filter.h in userspace builds.
> >
> > You're right. I'm going to send a v2.
> 
> Thanks for fixing my bug. I agree that it's better to do this
> independent of the sk_filter/bpf_prog patch.
> 
> > We should also cache the linux/filter.h header in the iptables
> > sources, would you send a patch for that? Thanks.
> 
> Will do.  Should I just import the latest version of the file, or is
> there a sync policy, such as that all kernel headers come from the
> same kernel release?

Right. The kernel header which is available after make headers_install.
Thanks.
