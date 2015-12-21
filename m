From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipv6/addrlabel: fix ip6addrlbl_get()
Date: Mon, 21 Dec 2015 11:37:38 -0800
Message-ID: <CAHA+R7OBGDZAFog7yrcJ4VPORE3ahgqMaZZs1B0XLwBh14Jg9g@mail.gmail.com>
References: <1450691685-29413-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450691685-29413-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 21, 2015 at 1:54 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> ip6addrlbl_get() has never worked. If ip6addrlbl_hold() succeeded,
> ip6addrlbl_get() will exit with '-ESRCH'. If ip6addrlbl_hold() failed,
> ip6addrlbl_get() will use about to be free ip6addrlbl_entry pointer.
>
> Fix this by inverting ip6addrlbl_hold() check.
>
> Fixes: 2a8cc6c89039 ("[IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Good catch!

Reviewed-by: Cong Wang <cwang@twopensource.com>
