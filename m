From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH 1/2] libceph: Remove unneeded stddef.h include
Date: Mon, 6 Feb 2017 11:19:12 +0100
Message-ID: <CAOi1vP-67FmaioEh_y9=J6Wp+G2+KmKhicy18-uKAPTy7t_1sw@mail.gmail.com>
References: <cover.1486276931.git.shorne@gmail.com> <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ceph Development <ceph-devel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Stafford Horne <shorne@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 5, 2017 at 8:07 AM, Stafford Horne <shorne@gmail.com> wrote:
> This was causing a build failure for openrisc when using musl and
> gcc 5.4.0 since the file is not available in the toolchain.
>
> It doesnt seem this is needed and removing it does not cause any build
> warnings for me.
>
> Signed-off-by: Stafford Horne <shorne@gmail.com>
> ---
>  net/ceph/snapshot.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/ceph/snapshot.c b/net/ceph/snapshot.c
> index 154683f..705414e 100644
> --- a/net/ceph/snapshot.c
> +++ b/net/ceph/snapshot.c
> @@ -18,8 +18,6 @@
>   * 02110-1301, USA.
>   */
>
> -#include <stddef.h>
> -
>  #include <linux/types.h>
>  #include <linux/export.h>
>  #include <linux/ceph/libceph.h>

Applied.

Thanks,

                Ilya
