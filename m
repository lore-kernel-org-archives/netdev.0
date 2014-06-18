From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: filter: fix upper BPF instruction limit
Date: Wed, 18 Jun 2014 15:48:05 -0700
Message-ID: <CAMEtUuzbPExM5dT+xDqbHtV5LZ3+E2Q0eq4xdmKWzLOZbTmuUQ@mail.gmail.com>
References: <20140618223457.GA31568@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Chema Gonzalez <chema@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140618223457.GA31568@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2014 at 3:34 PM, Kees Cook <keescook@chromium.org> wrote:
> The original checks (via sk_chk_filter) for instruction count uses ">",
> not ">=", so changing this in sk_convert_filter has the potential to break
> existing seccomp filters that used exactly BPF_MAXINSNS many instructions.
>
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org # v3.15+

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

I wonder how did you catch this? :)
Just code inspection or seccomp actually generating such programs?

Thanks!
