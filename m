From: Duc Dang <dhdang@apm.com>
Subject: Re: [PATCH 2/2] powerpc/44x: Add more changes for APM821XX EMAC driver
Date: Thu, 1 Mar 2012 12:05:14 +0700
Message-ID: <CADaLND=AwQ4+NDGevf2KzPE0M=jA7Crwe75+HPY35y_2W=xEnw@mail.gmail.com>
References: <1329466058-15969-1-git-send-email-dhdang@apm.com>
 <CA+5PVA5hciQSvfkodX-oP_kUZueiTp=0+t8X_0iHQ+ehU0ecOQ@mail.gmail.com>
 <20120229.132513.1607879808995168004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2590090146882615085=="
Cc: netdev@vger.kernel.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, jwboyer@gmail.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20120229.132513.1607879808995168004.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

--===============2590090146882615085==
Content-Type: multipart/alternative; boundary=f46d042f93fa8e2ae104ba276910

--f46d042f93fa8e2ae104ba276910
Content-Type: text/plain; charset=ISO-8859-1

Thanks, David and Josh.

Except the coding style problem that David mentioned, do you have other
comment about my patch set?

Regards,
Duc Dang.

On Thu, Mar 1, 2012 at 1:25 AM, David Miller <davem@davemloft.net> wrote:

> From: Josh Boyer <jwboyer@gmail.com>
> Date: Wed, 29 Feb 2012 08:43:46 -0500
>
> > On Fri, Feb 17, 2012 at 3:07 AM, Duc Dang <dhdang@apm.com> wrote:
> >> This patch includes:
> >>
> >>  Configure EMAC PHY clock source (clock from PHY or internal clock).
> >>
> >>  Do not advertise PHY half duplex capability as APM821XX EMAC does not
> >> support half duplex mode.
> >>
> >>  Add changes to support configuring jumbo frame for APM821XX EMAC.
> >>
> >> Signed-off-by: Duc Dang <dhdang@apm.com>
> >
> > This should have been sent to netdev.  CC'ing them now.
> >
> > Ben and David, I can take this change through the 4xx tree if it looks
> OK to
> > both of you.  The pre-requisite DTS patch will go through my tree, so it
> might
> > make sense to keep them together.
>
> Well the patch has coding style problems, for one:
>
> >> +                    dev->features |=
> (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE
> >> +                                    | EMAC_FTR_APM821XX_NO_HALF_DUPLEX
> >> +                                    | EMAC_FTR_460EX_PHY_CLK_FIX);
>
> Should be:
>
> >> +                    dev->features |=
> (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE |
> >> +                                      EMAC_FTR_APM821XX_NO_HALF_DUPLEX
> |
> >> +                                      EMAC_FTR_460EX_PHY_CLK_FIX);
>
> And this:
>
> >> +            dev->phy_feat_exc = (SUPPORTED_1000baseT_Half
> >> +                                    | SUPPORTED_100baseT_Half
> >> +                                    | SUPPORTED_10baseT_Half);
>
> Should be:
>
> >> +            dev->phy_feat_exc = (SUPPORTED_1000baseT_Half |
> >> +                                 SUPPORTED_100baseT_Half |
> >> +                                 SUPPORTED_10baseT_Half);
>

--f46d042f93fa8e2ae104ba276910
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Thanks, David and Josh.<br>
<br>
Except the coding style problem that David mentioned, do you have other com=
ment about my patch set?<br>
<br>
Regards,<br>
Duc Dang.<br><br><div class=3D"gmail_quote">On Thu, Mar 1, 2012 at 1:25 AM,=
 David Miller <span dir=3D"ltr">&lt;<a href=3D"mailto:davem@davemloft.net">=
davem@davemloft.net</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>

From: Josh Boyer &lt;<a href=3D"mailto:jwboyer@gmail.com">jwboyer@gmail.com=
</a>&gt;<br>
Date: Wed, 29 Feb 2012 08:43:46 -0500<br>
<br>
&gt; On Fri, Feb 17, 2012 at 3:07 AM, Duc Dang &lt;<a href=3D"mailto:dhdang=
@apm.com">dhdang@apm.com</a>&gt; wrote:<br>
&gt;&gt; This patch includes:<br>
&gt;&gt;<br>
&gt;&gt; =A0Configure EMAC PHY clock source (clock from PHY or internal clo=
ck).<br>
&gt;&gt;<br>
&gt;&gt; =A0Do not advertise PHY half duplex capability as APM821XX EMAC do=
es not<br>
&gt;&gt; support half duplex mode.<br>
&gt;&gt;<br>
&gt;&gt; =A0Add changes to support configuring jumbo frame for APM821XX EMA=
C.<br>
&gt;&gt;<br>
&gt;&gt; Signed-off-by: Duc Dang &lt;<a href=3D"mailto:dhdang@apm.com">dhda=
ng@apm.com</a>&gt;<br>
&gt;<br>
&gt; This should have been sent to netdev. =A0CC&#39;ing them now.<br>
&gt;<br>
&gt; Ben and David, I can take this change through the 4xx tree if it looks=
 OK to<br>
&gt; both of you. =A0The pre-requisite DTS patch will go through my tree, s=
o it might<br>
&gt; make sense to keep them together.<br>
<br>
Well the patch has coding style problems, for one:<br>
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev-&gt;features |=3D (EM=
AC_APM821XX_REQ_JUMBO_FRAME_SIZE<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| EMAC_FTR_APM821XX_NO_HALF_DUPLEX<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| EMAC_FTR_460EX_PHY_CLK_FIX);<br>
<br>
Should be:<br>
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev-&gt;features |=3D (EM=
AC_APM821XX_REQ_JUMBO_FRAME_SIZE |<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0EMAC_FTR_APM821XX_NO_HALF_DUPLEX |<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0EMAC_FTR_460EX_PHY_CLK_FIX);<br>
<br>
And this:<br>
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0dev-&gt;phy_feat_exc =3D (SUPPORTED_1000b=
aseT_Half<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| SUPPORTED_100baseT_Half<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| SUPPORTED_10baseT_Half);<br>
<br>
Should be:<br>
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0dev-&gt;phy_feat_exc =3D (SUPPORTED_1000b=
aseT_Half |<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
SUPPORTED_100baseT_Half |<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
SUPPORTED_10baseT_Half);<br>
</blockquote></div><br>

--f46d042f93fa8e2ae104ba276910--

--===============2590090146882615085==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============2590090146882615085==--
