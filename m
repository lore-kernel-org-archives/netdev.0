From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: ADSL/ATM linklayer tc shaping regression fix commits
	for stable
Date: Wed, 21 Aug 2013 10:10:37 -0700
Message-ID: <CAA93jw6negwFNRTh0BK2ha=QyT0L-MUrsP7yaLEnZszxg8Tc+A@mail.gmail.com>
References: <20130820132629.51618797@redhat.com>
	<20130820151650.GA18016@kroah.com>
	<20130821140350.2b953007@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4169961661626544835=="
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bufferbloat-list <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <20130821140350.2b953007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============4169961661626544835==
Content-Type: multipart/alternative; boundary=f46d043c820c90019404e47840e5

--f46d043c820c90019404e47840e5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 21, 2013 at 5:03 AM, Jesper Dangaard Brouer
<brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>wrote:

>
> On Tue, 20 Aug 2013 08:16:50 -0700
> Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> > On Tue, Aug 20, 2013 at 01:26:29PM +0200, Jesper Dangaard Brouer wrote:
> [...]
>
> > If there are issues with 3.10, that's a different story.
> >
> > > Refactor improvements (v3.11-rc1):
> > >  commit 130d3d68b52 (net_sched: psched_ratecfg_precompute()
> improvements)
>
> Needed because it fixes the accuracy of the rate calc.
>
> > > The linklayer ATM/ADSL fix, reached 3.11-rc6:
> > >  commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
>
> Needed because we broke userspace interface.
>
> > David sends me the networking patches for the stable tree, and if he
> > thinks these are applicable, then I'll take them.
>
> DaveM, please?  What do you want me to do, submit this req/patches someho=
w?
>
> (Can see that is not currently on your stable queue via:
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*)
>
>
+1 Dealing with the busted DSL stuff since 3.8 has been no fun and it would
be nice if these last fixes made it into 3.10.X at least so router/fw
distros can pick them up more easily. The difference in dsl behavior since
the bustage in 3.8 to the saner now is remarkable.

Probably not meeting the criteria for 3.10-stable inclusion (as they aren't
exactly bugfixes) are the tiny improvements to the flow dissector made in
3.11 for better ipip, ipv6 encapsulation, and 802.1ad support, but I
thought I'd mention them so other fq_codel folk pick them up that need them=
.

Not ready for any tree and increasingly doubtful for 3.12 are some
improvements under test to codel and cisco's sch_pie, if anyone wants to
play with them, let me know off list.


> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>



--=20
Dave T=E4ht

Fixing bufferbloat with cerowrt:
http://www.teklibre.com/cerowrt/subscribe.html

--f46d043c820c90019404e47840e5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Wed, Aug 21, 2013 at 5:03 AM, Jesper Dangaard Brouer <span dir=
=3D"ltr">&lt;<a href=3D"mailto:brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" target=3D"_blank">brouer@=
redhat.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im"><br>
On Tue, 20 Aug 2013 08:16:50 -0700<br>
Greg Kroah-Hartman &lt;<a href=3D"mailto:gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org">gregkh=
@linuxfoundation.org</a>&gt; wrote:<br>
&gt; On Tue, Aug 20, 2013 at 01:26:29PM +0200, Jesper Dangaard Brouer wrote=
:<br>
</div>[...]<br>
<div class=3D"im"><br>
&gt; If there are issues with 3.10, that&#39;s a different story.<br>
&gt;<br>
&gt; &gt; Refactor improvements (v3.11-rc1):<br>
&gt; &gt; =A0commit 130d3d68b52 (net_sched: psched_ratecfg_precompute() imp=
rovements)<br>
<br>
</div>Needed because it fixes the accuracy of the rate calc.<br>
<div class=3D"im"><br>
&gt; &gt; The linklayer ATM/ADSL fix, reached 3.11-rc6:<br>
&gt; &gt; =A0commit 8a8e3d84b17 (net_sched: restore &quot;linklayer atm&quo=
t; handling)<br>
<br>
</div>Needed because we broke userspace interface.<br>
<div class=3D"im"><br>
&gt; David sends me the networking patches for the stable tree, and if he<b=
r>
&gt; thinks these are applicable, then I&#39;ll take them.<br>
<br>
</div>DaveM, please? =A0What do you want me to do, submit this req/patches =
somehow?<br>
<br>
(Can see that is not currently on your stable queue via:<br>
<a href=3D"http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*" targ=
et=3D"_blank">http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*</a=
>)<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br></div></div></blockquote><div><=
br></div><div>+1 Dealing with the busted DSL stuff since 3.8 has been no fu=
n and it would be nice if these last fixes made it into 3.10.X at least so =
router/fw distros can pick them up more easily. The difference in dsl behav=
ior since the bustage in 3.8 to the saner now is remarkable.<br>
<br></div><div>Probably not meeting the criteria for 3.10-stable inclusion =
(as they aren&#39;t exactly bugfixes) are the tiny improvements to the flow=
 dissector made in 3.11 for better ipip, ipv6 encapsulation, and 802.1ad su=
pport, but I thought I&#39;d mention them so other fq_codel folk pick them =
up that need them.<br>
<br></div><div>Not ready for any tree and increasingly doubtful for 3.12 ar=
e some improvements under test to codel and cisco&#39;s sch_pie, if anyone =
wants to play with them, let me know off list.<br></div><div>=A0<br></div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">
--<br>
Best regards,<br>
=A0 Jesper Dangaard Brouer<br>
=A0 MSc.CS, Sr. Network Kernel Developer at Red Hat<br>
=A0 Author of <a href=3D"http://www.iptv-analyzer.org" target=3D"_blank">ht=
tp://www.iptv-analyzer.org</a><br>
=A0 LinkedIn: <a href=3D"http://www.linkedin.com/in/brouer" target=3D"_blan=
k">http://www.linkedin.com/in/brouer</a><br>
</div></div></blockquote></div><br><br clear=3D"all"><br>-- <br>Dave T=E4ht=
<br><br>Fixing bufferbloat with cerowrt: <a href=3D"http://www.teklibre.com=
/cerowrt/subscribe.html" target=3D"_blank">http://www.teklibre.com/cerowrt/=
subscribe.html</a>=20
</div></div>

--f46d043c820c90019404e47840e5--

--===============4169961661626544835==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bloat mailing list
Bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
https://lists.bufferbloat.net/listinfo/bloat

--===============4169961661626544835==--
