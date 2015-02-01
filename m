From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 2/3] netlabel: Deletion of an unnecessary check before the
 function call "cipso_v4_doi_free"
Date: Sat, 31 Jan 2015 21:22:02 -0500
Message-ID: <CAHC9VhTJT+xKf8QiPRTDvRDS4z5mY-UV05BFj710OchH9xkLbw@mail.gmail.com>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54CD45B6.6010703@users.sourceforge.net>
	<54CD4AF0.7070102@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <54CD4AF0.7070102@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2015 at 4:36 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 31 Jan 2015 19:35:59 +0100
>
> The cipso_v4_doi_free() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/netlabel/netlabel_cipso_v4.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Acked-by: Paul Moore <paul@paul-moore.com>

> diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
> index 1796253..7fd1104 100644
> --- a/net/netlabel/netlabel_cipso_v4.c
> +++ b/net/netlabel/netlabel_cipso_v4.c
> @@ -324,8 +324,7 @@ static int netlbl_cipsov4_add_std(struct genl_info *info,
>         return 0;
>
>  add_std_failure:
> -       if (doi_def)
> -               cipso_v4_doi_free(doi_def);
> +       cipso_v4_doi_free(doi_def);
>         return ret_val;
>  }
>
> --
> 2.2.2
>



-- 
paul moore
www.paul-moore.com
