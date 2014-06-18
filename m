From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: fix upper BPF instruction limit
Date: Thu, 19 Jun 2014 00:43:28 +0200
Message-ID: <53A21610.1040104@redhat.com>
References: <20140618223457.GA31568@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	Chema Gonzalez <chema@google.com>, netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140618223457.GA31568@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2014 12:34 AM, Kees Cook wrote:
> The original checks (via sk_chk_filter) for instruction count uses ">",
> not ">=", so changing this in sk_convert_filter has the potential to break
> existing seccomp filters that used exactly BPF_MAXINSNS many instructions.
>
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
