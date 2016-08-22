From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v05 21/72] include/uapi/linux/if_pppox.h: include
 linux/if.h
Date: Mon, 22 Aug 2016 12:37:45 -0700
Message-ID: <20160822123745.7921a88d@xeon-e3>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
        <1471890809-4383-22-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-22-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Aug 2016 20:32:38 +0200
Mikko Rapeli <mikko.rapeli@iki.fi> wrote:

> Fixes userspace compilation error:
>=20
> error: =E2=80=98IFNAMSIZ=E2=80=99 undeclared here (not in a function)
>=20
> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> ---
>  include/uapi/linux/if_pppox.h | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppox.h
> index e128769..473c3c4 100644
> --- a/include/uapi/linux/if_pppox.h
> +++ b/include/uapi/linux/if_pppox.h
> @@ -21,6 +21,7 @@
>  #include <asm/byteorder.h>
> =20
>  #include <linux/socket.h>
> +#include <linux/if.h>
>  #include <linux/if_ether.h>
>  #include <linux/if_pppol2tp.h>
> =20

I went back to the first patch in LKML for this series.
It seems your goal is that every include file should be standalone,
i.e it must include every definition it uses.

I disagree with this premise. It just makes things harder to maintain with
no real gain for any existing program.  What is the motivation for all this
useless churn? Is there some silly style rule that should be fixed instead?
