From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] audit: pass int* to nlmsg_next
Date: Fri, 29 Mar 2013 18:54:09 +0400
Message-ID: <5155AB11.60009@cogentembedded.com>
References: <1364506289-9146-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, honkiko@gmail.com, tgraf@suug.ch
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364506289-9146-1-git-send-email-alex.mihai.c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 29-03-2013 1:31, Alexandru Copot wrote:

> Commit 941912133025926307c7a65b203fa38403b1063a

    Please also specify the summary line of that commit in parens (or h=
owever=20
you like).
    With that, you can add my:

Acked-by: Sergei Shtylyov <segei.shtylyov@cogentembedded.com>

> replaced the macros
> NLMSG_NEXT with calls to nlmsg_next which produces this warning:

> kernel/audit.c: In function =E2=80=98audit_receive_skb=E2=80=99:
> kernel/audit.c:928:3: warning: passing argument 2 of =E2=80=98nlmsg_n=
ext=E2=80=99 makes pointer from integer without a cast
> In file included from include/net/rtnetlink.h:5:0,
>                   from include/net/neighbour.h:28,
>                   from include/net/dst.h:17,
>                   from include/net/sock.h:68,
>                   from kernel/audit.c:55:
> include/net/netlink.h:359:1: note: expected =E2=80=98int *=E2=80=99 b=
ut argument is of type =E2=80=98int=E2=80=99

> Fix this by sending the intended pointer.

> Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>

WBR, Sergei
