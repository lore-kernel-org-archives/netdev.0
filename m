From: Wei Liu <liuw@liuw.name>
Subject: Re: [PATCH] xen: netback: remove redundant xenvif_put
Date: Mon, 18 Feb 2013 20:58:32 +0000
Message-ID: <CAOsiSVVb1idFC3wTcZLzUrsDN7z8asFHFRsVfoHERb--y_qz4w@mail.gmail.com>
References: <1361219360-29176-1-git-send-email-drjones@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3340379250672368185=="
Cc: netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <ian.campbell@citrix.com>, linux-kernel@vger.kernel.org
To: Andrew Jones <drjones@redhat.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1361219360-29176-1-git-send-email-drjones@redhat.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============3340379250672368185==
Content-Type: multipart/alternative; boundary=e89a8f3b9d9fad641a04d605fed1

--e89a8f3b9d9fad641a04d605fed1
Content-Type: text/plain; charset=UTF-8

On Mon, Feb 18, 2013 at 8:29 PM, Andrew Jones <drjones@redhat.com> wrote:

> netbk_fatal_tx_err() calls xenvif_carrier_off(), which does
> a xenvif_put(). As callers of netbk_fatal_tx_err should only
> have one reference to the vif at this time, then the xenvif_put
> in netbk_fatal_tx_err is one too many.
>
>
Hmm... we had a discussion on this not long ago.

http://marc.info/?l=xen-devel&m=136084174026977&w=2

Do you actually experiencing problem?


Wei.



> Signed-off-by: Andrew Jones <drjones@redhat.com>
> ---
>  drivers/net/xen-netback/netback.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/xen-netback/netback.c
> b/drivers/net/xen-netback/netback.c
> index 2b9520c..c23b9ec 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -893,7 +893,6 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  {
>         netdev_err(vif->dev, "fatal error; disabling device\n");
>         xenvif_carrier_off(vif);
> -       xenvif_put(vif);
>  }
>
>  static int netbk_count_requests(struct xenvif *vif,
> --
> 1.8.1.2
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>

--e89a8f3b9d9fad641a04d605fed1
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Mon, Feb 18, 2013 at 8:29 PM, Andrew Jones <span dir=3D"ltr">&lt=
;<a href=3D"mailto:drjones@redhat.com" target=3D"_blank">drjones@redhat.com=
</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">netbk_fatal_tx_err() calls xenvif_carrier_off(), which doe=
s<br>


a xenvif_put(). As callers of netbk_fatal_tx_err should only<br>
have one reference to the vif at this time, then the xenvif_put<br>
in netbk_fatal_tx_err is one too many.<br>
<br></blockquote><div><br></div><div style><div>Hmm... we had a discussion =
on this not long ago.</div><div><br></div><div><a href=3D"http://marc.info/=
?l=3Dxen-devel&amp;m=3D136084174026977&amp;w=3D2">http://marc.info/?l=3Dxen=
-devel&amp;m=3D136084174026977&amp;w=3D2</a><br>

</div><div><br></div><div>Do you actually experiencing problem?</div><div><=
br></div><div><br></div><div>Wei.</div><div><br></div></div><div>=C2=A0</di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;borde=
r-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid=
;padding-left:1ex">


Signed-off-by: Andrew Jones &lt;<a href=3D"mailto:drjones@redhat.com">drjon=
es@redhat.com</a>&gt;<br>
---<br>
=C2=A0drivers/net/xen-netback/netback.c | 1 -<br>
=C2=A01 file changed, 1 deletion(-)<br>
<br>
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/ne=
tback.c<br>
index 2b9520c..c23b9ec 100644<br>
--- a/drivers/net/xen-netback/netback.c<br>
+++ b/drivers/net/xen-netback/netback.c<br>
@@ -893,7 +893,6 @@ static void netbk_fatal_tx_err(struct xenvif *vif)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_err(vif-&gt;dev, &quot;fatal error; disa=
bling device\n&quot;);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 xenvif_carrier_off(vif);<br>
- =C2=A0 =C2=A0 =C2=A0 xenvif_put(vif);<br>
=C2=A0}<br>
<br>
=C2=A0static int netbk_count_requests(struct xenvif *vif,<br>
<span class=3D""><font color=3D"#888888">--<br>
1.8.1.2<br>
<br>
<br>
_______________________________________________<br>
Xen-devel mailing list<br>
<a href=3D"mailto:Xen-devel@lists.xen.org">Xen-devel@lists.xen.org</a><br>
<a href=3D"http://lists.xen.org/xen-devel" target=3D"_blank">http://lists.x=
en.org/xen-devel</a><br>
</font></span></blockquote></div><br></div></div>

--e89a8f3b9d9fad641a04d605fed1--


--===============3340379250672368185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============3340379250672368185==--
