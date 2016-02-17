From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] rtnl: RTM_GETNETCONF: fix wrong return value
Date: Wed, 17 Feb 2016 14:57:38 -0800
Message-ID: <CAM_iQpWUFmwoC8ovyE-+QKT1X9m+oyQWRSues72Ntttbi59jew@mail.gmail.com>
References: <1455676996-6335-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Anton Protopopov <a.s.protopopov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455676996-6335-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 16, 2016 at 6:43 PM, Anton Protopopov
<a.s.protopopov@gmail.com> wrote:
> An error response from a RTM_GETNETCONF request can return the positive
> error value EINVAL in the struct nlmsgerr that can mislead userspace.
>
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

LGTM,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
