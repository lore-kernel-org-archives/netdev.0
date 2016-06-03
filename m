From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] soreuseport: add compat case for setsockopt
 SO_ATTACH_REUSEPORT_CBPF
Date: Fri, 3 Jun 2016 21:11:24 +0300
Message-ID: <4cec14e5-2950-be26-1ffa-8d604bdb2fb5@cogentembedded.com>
References: <20160603171805.GA3664@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-parisc@vger.kernel.org
To: Helge Deller <deller@gmx.de>, Craig Gallek <kraig@google.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20160603171805.GA3664@ls3530.box>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/03/2016 08:18 PM, Helge Deller wrote:

> Commit 538950a ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")

    At least 12 digits must be specified for SHA1. checkpatch.pl should've 
caught this.

> missed to add the compat case for the SO_ATTACH_REUSEPORT_CBPF
> setsockoption() option.
>
> Since both SO_ATTACH_FILTER and SO_ATTACH_REUSEPORT_CBPF use a struct
> sock_fprog let's combine the handling of both.
>
> Signed-off-by: Helge Deller <deller@gmx.de>
>
> diff --git a/net/compat.c b/net/compat.c
> index 5cfd26a..7e2aac9 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -309,7 +309,7 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
>  	__scm_destroy(scm);
>  }
>
> -static int do_set_attach_filter(struct socket *sock, int level, int optname,
> +static int do_sockopt_fix_sock_fprog(struct socket *sock, int level, int optname,
>  				char __user *optval, unsigned int optlen)

    You need to realign this line now.

[...]

WBR, Sergei

