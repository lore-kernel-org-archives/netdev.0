From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Thu, 6 Jan 2011 11:07:56 -0800
Message-ID: <AANLkTin+pgnTs67odj2qtrMD3AzgQ+Wv43a6NbBy6G8t@mail.gmail.com>
References: <1294306655-22033-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1294306655-22033-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 6, 2011 at 1:37 AM, Changli Gao <xiaosuo@gmail.com> wrote:
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
> =C2=A0drivers/net/ppp_async.c =C2=A0 | =C2=A0 10 +++++-----
> =C2=A0drivers/net/ppp_deflate.c | =C2=A0 =C2=A09 ++++-----
> =C2=A0drivers/net/ppp_generic.c | =C2=A0 =C2=A09 ++++-----
> =C2=A0drivers/net/ppp_mppe.c =C2=A0 =C2=A0| =C2=A0 =C2=A07 +++----
> =C2=A0drivers/net/ppp_synctty.c | =C2=A0 =C2=A03 ++-
> =C2=A05 files changed, 18 insertions(+), 20 deletions(-)
> diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
> index 78d70a6..cbe1e13 100644
> --- a/drivers/net/ppp_async.c
> +++ b/drivers/net/ppp_async.c
> @@ -32,6 +32,7 @@
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/jiffies.h>
> =C2=A0#include <linux/slab.h>
> +#include <linux/unaligned/be_struct.h>

#include <asm/unaligned.h>

Same for the other occurances, otherwise looks OK.

Harvey
