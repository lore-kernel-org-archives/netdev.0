From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH] ceph:Remove unused goto labels in decode crush map functions
Date: Sat, 3 Oct 2015 07:44:02 +0200
Message-ID: <CAOi1vP9ZdhBRf85UM0TFOtF33PhMJHQddy9dOar74W6y=DWeJw@mail.gmail.com>
References: <1443815319-20772-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443815319-20772-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 2, 2015 at 9:48 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This removes unused goto labels in decode crush map functions related
> to error paths due to them never being used on any error path for these
> particular functions in the file, osdmap.c.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/ceph/osdmap.c | 10 ----------
>  1 file changed, 10 deletions(-)
>
> diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
> index 7d8f581..2f8e41c 100644
> --- a/net/ceph/osdmap.c
> +++ b/net/ceph/osdmap.c
> @@ -59,8 +59,6 @@ static int crush_decode_uniform_bucket(void **p, void *end,
>         ceph_decode_need(p, end, (1+b->h.size) * sizeof(u32), bad);
                                                                ^^^
>         b->item_weight = ceph_decode_32(p);
>         return 0;
> -bad:
   ^^^
> -       return -EINVAL;
>  }

I realize that these macros are sneaky, but you should at least
compile-test your patches before you send them out.

Thanks,

                Ilya
