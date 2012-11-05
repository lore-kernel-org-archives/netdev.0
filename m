From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 0/4] Support the MX6 FEC as a PTP hardware clock
Date: Mon, 5 Nov 2012 19:23:39 +0800
Message-ID: <CAHrpEqRCVv1JLGz04Gb8q=X3x_UGG4wEvr2TBQjU_2bK8vhJOA@mail.gmail.com>
References: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
 <20121101.123027.1332984905040252720.davem@davemloft.net>
 <CAHrpEqRuy=kewK-592RphVfJnNoma2CPZytoTqLc45HeT53hRQ@mail.gmail.com>
 <20121102084324.GA2486@netboy.at.omicron.at>
 <1351898728.2703.30.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4369104646502332726=="
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Richard Cochran <richardcochran@gmail.com>,
 "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1351898728.2703.30.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============4369104646502332726==
Content-Type: multipart/alternative; boundary=f46d0444696992b77804cdbdb730

--f46d0444696992b77804cdbdb730
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

=D4=DA 2012=C4=EA11=D4=C23=C8=D5=D0=C7=C6=DA=C1=F9=A3=ACBen Hutchings =D0=
=B4=B5=C0=A3=BA

> On Fri, 2012-11-02 at 09:43 +0100, Richard Cochran wrote:
> > On Fri, Nov 02, 2012 at 10:36:09AM +0800, Frank Li wrote:
> > > >
> > > > All applied to net-next.
> > > >
> > > > Please make sure your changes are in sync with Ben's PTP/PPS
> > > > Kconfig changes of today, and send me any changes if necessary.
> > > >
> > >
> > > Thank you very much.
> > > I checked Ben's patch, which not affect FEC.
> >
> > Maybe just remove the Kconfig line "select PPS".
>
> More than that: FEC should select PTP_1588_CLOCK,


okay, I will do that.


> FEC_PTP should be
> removed and all the conditional code made unconditional.  Alternately,
> if that would cost too much (in terms of performance or memory) on some
> systems where the driver is used, FEC_PTP should default to 'y'.


Bd description will be difference between no PTP and PTP hardware,
So driver will not incompatible at two kind of hardware.

I can set it default is Y at MX6 platform.


> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>

--f46d0444696992b77804cdbdb730
Content-Type: text/html; charset=GB2312
Content-Transfer-Encoding: quoted-printable

<br><br>=D4=DA 2012=C4=EA11=D4=C23=C8=D5=D0=C7=C6=DA=C1=F9=A3=ACBen Hutchin=
gs  =D0=B4=B5=C0=A3=BA<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Fri, 2012-11-02=
 at 09:43 +0100, Richard Cochran wrote:<br>
&gt; On Fri, Nov 02, 2012 at 10:36:09AM +0800, Frank Li wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; All applied to net-next.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Please make sure your changes are in sync with Ben&#39;s PTP=
/PPS<br>
&gt; &gt; &gt; Kconfig changes of today, and send me any changes if necessa=
ry.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Thank you very much.<br>
&gt; &gt; I checked Ben&#39;s patch, which not affect FEC.<br>
&gt;<br>
&gt; Maybe just remove the Kconfig line &quot;select PPS&quot;.<br>
<br>
More than that: FEC should select PTP_1588_CLOCK,&nbsp;</blockquote><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex"></blockquote><div><br></div><div>okay, I will do th=
at.</div>
<div>&nbsp;<br></div><div></div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">FEC_PTP shou=
ld be<br>
removed and all the conditional code made unconditional. &nbsp;Alternately,=
<br>
if that would cost too much (in terms of performance or memory) on some<br>
systems where the driver is used, FEC_PTP should default to &#39;y&#39;.</b=
lockquote><div><br></div><div>Bd description will be difference between no =
PTP and PTP hardware,&nbsp;</div><div>So driver will not incompatible at tw=
o kind of hardware.</div>
<div><br></div><div>I can set it default is Y at MX6 platform.&nbsp;<span><=
/span></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Ben.<br>
<br>
--<br>
Ben Hutchings, Staff Engineer, Solarflare<br>
Not speaking for my employer; that&#39;s the marketing department&#39;s job=
.<br>
They asked us to note that Solarflare product names are trademarked.<br>
<br>
</blockquote>

--f46d0444696992b77804cdbdb730--


--===============4369104646502332726==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============4369104646502332726==--
