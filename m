From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing
	ndo_uninit()
Date: Sat, 8 Apr 2017 16:14:59 +0200
Message-ID: <CA+Nub0Zz6pB5+ho4FeyCJ=GJTyXXWE0dhcOC5zB3gCkusZKObw@mail.gmail.com>
References: <20170408114159.12722-1-idosch@mellanox.com>
	<20170408114159.12722-2-idosch@mellanox.com>
	<20170408093042.20b08c5d@plumbers-lap.home.lan>
	<20170408134938.GA28955@splinter>
	<59220a2b-aa54-844d-cda5-63a42b88f188@cumulusnetworks.com>
	<20170408101401.10ee916e@plumbers-lap.home.lan>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a1141bc1e1936ee054ca85eb8
Cc: mlxsw@mellanox.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, peter@svinota.eu,
	bridge@lists.linux-foundation.org, Ido Schimmel <idosch@mellanox.com>,
	Ido Schimmel <idosch@idosch.org>, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170408101401.10ee916e@plumbers-lap.home.lan>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--001a1141bc1e1936ee054ca85eb8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Dne 8. 4. 2017 10:14 napsal u=C5=BEivatel "Stephen Hemminger" <
stephen@networkplumber.org>:

On Sat, 8 Apr 2017 17:05:48 +0300
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> On 08/04/17 16:49, Ido Schimmel wrote:
> > On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote:
> >> On Sat, 8 Apr 2017 14:41:58 +0300
> >> <idosch@mellanox.com> wrote:
> >>
> >>>  static void br_dev_free(struct net_device *dev)
> >>>  {
> >>> - struct net_bridge *br =3D netdev_priv(dev);
> >>> -
> >>> - free_percpu(br->stats);
> >>>   free_netdev(dev);
> >>>  }
> >>>
> >>
> >> Since the only thing left is free_netdev, you can now just set
dev->destructor
> >> to be free_netdev.
> >
> > Fine.
> >
> > Beside stylistic issues, I would appreciate comments on how this should
> > be handled. Are we reverting the patch in the Fixes line or applying
> > this patchset?
> >
> > I prefer the first option. Then after net is merged into net-next I can
> > re-post this patchset with the requested changes.
> >
>
> +1
>
>

If this fixes the issue, then the one fix should go to stable, net and
net-next.
There is no good reason to have two versions.

+1

--001a1141bc1e1936ee054ca85eb8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">Dne 8. 4. 2017 10:14 napsal u=C5=BEivatel &quot;Stephen Hemminger=
&quot; &lt;<a href=3D"mailto:stephen@networkplumber.org">stephen@networkplu=
mber.org</a>&gt;:<br type=3D"attribution"><blockquote class=3D"quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div cla=
ss=3D"elided-text">On Sat, 8 Apr 2017 17:05:48 +0300<br>
Nikolay Aleksandrov &lt;<a href=3D"mailto:nikolay@cumulusnetworks.com">niko=
lay@cumulusnetworks.com</a>&gt; wrote:<br>
<br>
&gt; On 08/04/17 16:49, Ido Schimmel wrote:<br>
&gt; &gt; On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote=
:<br>
&gt; &gt;&gt; On Sat, 8 Apr 2017 14:41:58 +0300<br>
&gt; &gt;&gt; &lt;<a href=3D"mailto:idosch@mellanox.com">idosch@mellanox.co=
m</a>&gt; wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;&gt;=C2=A0 static void br_dev_free(struct net_device *dev)<br>
&gt; &gt;&gt;&gt;=C2=A0 {<br>
&gt; &gt;&gt;&gt; - struct net_bridge *br =3D netdev_priv(dev);<br>
&gt; &gt;&gt;&gt; -<br>
&gt; &gt;&gt;&gt; - free_percpu(br-&gt;stats);<br>
&gt; &gt;&gt;&gt;=C2=A0 =C2=A0free_netdev(dev);<br>
&gt; &gt;&gt;&gt;=C2=A0 }<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Since the only thing left is free_netdev, you can now just se=
t dev-&gt;destructor<br>
&gt; &gt;&gt; to be free_netdev.<br>
&gt; &gt;<br>
&gt; &gt; Fine.<br>
&gt; &gt;<br>
&gt; &gt; Beside stylistic issues, I would appreciate comments on how this =
should<br>
&gt; &gt; be handled. Are we reverting the patch in the Fixes line or apply=
ing<br>
&gt; &gt; this patchset?<br>
&gt; &gt;<br>
&gt; &gt; I prefer the first option. Then after net is merged into net-next=
 I can<br>
&gt; &gt; re-post this patchset with the requested changes.<br>
&gt; &gt;<br>
&gt;<br>
&gt; +1<br>
&gt;<br>
&gt;<br>
<br>
</div>If this fixes the issue, then the one fix should go to stable, net an=
d net-next.<br>
There is no good reason to have two versions.<br>
<br>
</blockquote></div>+1</div></div></div>

--001a1141bc1e1936ee054ca85eb8--
