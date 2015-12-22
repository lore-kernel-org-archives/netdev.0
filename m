From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net: user-controllable kmalloc size in __sctp_setsockopt_connectx
Date: Tue, 22 Dec 2015 19:06:10 -0200
Message-ID: <20151222210610.GA5438@mrl.redhat.com>
References: <CACT4Y+Ztb5cw2SGqxHiOBq9FgDs3J12Wk9iG0NaNvdunM_ex-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Ztb5cw2SGqxHiOBq9FgDs3J12Wk9iG0NaNvdunM_ex-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Dec 22, 2015 at 09:13:54PM +0100, Dmitry Vyukov wrote:
> Hello,
...
> 
>  [<ffffffff8576a326>] __sctp_setsockopt_connectx+0xc6/0x150
> net/sctp/socket.c:1318
>  [<     inline     >] sctp_getsockopt_connectx3 net/sctp/socket.c:1410
>  [<ffffffff8577a22e>] sctp_getsockopt+0x25ee/0x3e00 net/sctp/socket.c:6007
>  [<ffffffff84ba2d65>] sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2601
>  [<     inline     >] SYSC_getsockopt net/socket.c:1782
>  [<ffffffff84ba0512>] SyS_getsockopt+0x142/0x230 net/socket.c:1764
>  [<ffffffff85cce8b6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185

This is similar to that other one. I'll send a patch for it tomorrow.

Thanks,
Marcelo
