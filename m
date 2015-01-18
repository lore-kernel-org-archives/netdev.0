From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn:gigaset:Remove unneeded TODO comment for the function,gigaset_procinfo
 in capi.c
Date: Sun, 18 Jan 2015 14:09:48 +0100
Message-ID: <54BBB09C.6010206@imap.cc>
References: <1421519027-22410-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, gigaset307x-common@lists.sourceforge.ne,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>, hjlipp@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421519027-22410-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.01.2015 um 19:23 schrieb Nicholas Krause:
> This removes the no longer needed TODO comment for questioning if
> the function,gigaset_procinfo needs to do more work internally. This
> comment is no longer needed due to the function's intended use to be
> returning the name of the structure pointer passed to this function
> of type,capi_ctr. In addition due to this the function's comments
> related to it's intended job are changed to state it returns rather
> then builds the description for the structure and also that the
> function doesn't build the name string but returns the already
> generated one passed to gigaset_procinfo by the structure passed
> to this function.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Acked-by: Tilman Schmidt <tilman@imap.cc>

Thanks,
Tilman

> ---
>  drivers/isdn/gigaset/capi.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.=
c
> index ccec777..c4d666e 100644
> --- a/drivers/isdn/gigaset/capi.c
> +++ b/drivers/isdn/gigaset/capi.c
> @@ -2336,14 +2336,14 @@ static u16 gigaset_send_message(struct capi_c=
tr *ctr, struct sk_buff *skb)
>  }
> =20
>  /**
> - * gigaset_procinfo() - build single line description for controller
> + * gigaset_procinfo() - return single line description for controlle=
r
>   * @ctr:	controller descriptor structure.
>   *
> - * Return value: pointer to generated string (null terminated)
> + * Return value: pointer to already generated string (null terminate=
d)
>   */
>  static char *gigaset_procinfo(struct capi_ctr *ctr)
>  {
> -	return ctr->name;	/* ToDo: more? */
> +	return ctr->name;
>  }
> =20
>  static int gigaset_proc_show(struct seq_file *m, void *v)
>=20

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
