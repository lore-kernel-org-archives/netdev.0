From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: define __packed for the userspace code
Date: Sun, 22 Aug 2010 19:23:42 +0800
Message-ID: <AANLkTin1BOgHBc4sTwFAmQhKFNvZ+90herc4Dsh9P8y2@mail.gmail.com>
References: <1282475544-24708-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282475544-24708-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 22, 2010 at 7:12 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> This commit
>
> =A0commit bc10502dba37d3b210efd9f3867212298f13b78e
> =A0Author: Eric Dumazet <eric.dumazet@gmail.com>
> =A0Date: =A0 Thu Jun 3 03:21:52 2010 -0700
>
> =A0 =A0net: use __packed annotation
>
> makes use of __packed in the userspace code. So we'd better define __=
packed
> for the userspace code too.
>

Oh, sorry. This patch can't work as include/linux/compiler.h isn't
exported to the userspace. But where should we define __packed for the
userspace code? include/linux/types.h?


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
