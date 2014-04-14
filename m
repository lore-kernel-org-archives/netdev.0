From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] seccomp: fix memory leak on filter attach
Date: Mon, 14 Apr 2014 20:23:58 +0200
Message-ID: <534C27BE.9020709@redhat.com>
References: <20140414171114.GA31384@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Masami Ichikawa <masami256@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Will Drewry <wad@chromium.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	James Morris <james.l.morris@oracle.com>, davem@davemloft.net,
	eparis@redhat.com, netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414171114.GA31384@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2014 07:11 PM, Kees Cook wrote:
> This sets the correct error code when final filter memory is unavailable,
> and frees the raw filter no matter what.
>
> unreferenced object 0xffff8800d6ea4000 (size 512):
>    comm "sshd", pid 278, jiffies 4294898315 (age 46.653s)
>    hex dump (first 32 bytes):
>      21 00 00 00 04 00 00 00 15 00 01 00 3e 00 00 c0  !...........>...
>      06 00 00 00 00 00 00 00 21 00 00 00 00 00 00 00  ........!.......
>    backtrace:
>      [<ffffffff8151414e>] kmemleak_alloc+0x4e/0xb0
>      [<ffffffff811a3a40>] __kmalloc+0x280/0x320
>      [<ffffffff8110842e>] prctl_set_seccomp+0x11e/0x3b0
>      [<ffffffff8107bb6b>] SyS_prctl+0x3bb/0x4a0
>      [<ffffffff8152ef2d>] system_call_fastpath+0x1a/0x1f
>      [<ffffffffffffffff>] 0xffffffffffffffff
>
> Reported-by: Masami Ichikawa <masami256@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org

Acked-by: Daniel Borkmann <dborkman@redhat.com>
