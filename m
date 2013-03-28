From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?= <socketpair@gmail.com>
Subject: network namespace + bridge visibility
Date: Fri, 29 Mar 2013 00:17:16 +0600
Message-ID: <CAEmTpZH80KrDoQb0KRJNYPsEDCrRg6qLVxLXrcgskLmXDyFMzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=00248c7118151d5d2c04d9002ac9
To: Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

--00248c7118151d5d2c04d9002ac9
Content-Type: text/plain; charset=UTF-8

==========================
mmarkk@imac:~# brctl addbr qwe
mmarkk@imac:~# unshare -n /bin/bash
root@imac:~# ip link
14: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
root@imac:~# brctl show
bridge name bridge id STP enabled interfaces
qwe 8000.000000000000 no
root@imac:~# brctl delbr qwe
bridge qwe doesn't exist; can't delete it
=============================

So, network device is not available, but present in list of bridges. This
is the bug, as I think.

Reproducible in linux kernels 3.8.2 and 3.2.0

-- 
Segmentation fault

--00248c7118151d5d2c04d9002ac9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style=3D"font-family:arial,sans-serif;font-size:13px"=
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D</div><div style=3D"font-family:arial,sans-serif;font-size:13px">mmar=
kk@imac:~# brctl addbr qwe<br></div><div style=3D"font-family:arial,sans-se=
rif;font-size:13px">
mmarkk@imac:~# unshare -n /bin/bash</div><div style=3D"font-family:arial,sa=
ns-serif;font-size:13px"><div>root@imac:~# ip link<br></div><div>14: lo: &l=
t;LOOPBACK&gt; mtu 16436 qdisc noop state DOWN=C2=A0</div><div>=C2=A0 =C2=
=A0 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00</div>
<div style=3D"font-family:arial;font-size:small"></div></div><div style=3D"=
font-family:arial,sans-serif;font-size:13px">root@imac:~# brctl show</div><=
div style=3D"font-family:arial,sans-serif;font-size:13px">bridge name<span =
style=3D"white-space:pre-wrap">	</span>bridge id<span style=3D"white-space:=
pre-wrap">		</span>STP enabled<span style=3D"white-space:pre-wrap">	</span>=
interfaces</div>
<div style=3D"font-family:arial,sans-serif;font-size:13px">qwe<span style=
=3D"white-space:pre-wrap">		</span>8000.000000000000<span style=3D"white-sp=
ace:pre-wrap">	</span>no<span style=3D"white-space:pre-wrap">		</span></div=
><div style=3D"font-family:arial,sans-serif;font-size:13px">
<span style=3D"font-size:small">root@imac:~# brctl delbr qwe</span><br></di=
v><div><div><font face=3D"arial, sans-serif">bridge qwe doesn&#39;t exist; =
can&#39;t delete it</font></div><div style=3D"font-family:arial,sans-serif;=
font-size:13px">
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D</div></div><div><br></div><div>So, network device is not avail=
able, but present in list of bridges. This is the bug, as I think.<br></div=
><div style><br></div><div style>Reproducible in linux kernels 3.8.2 and 3.=
2.0</div>
<div><br></div>-- <br>Segmentation fault
</div>

--00248c7118151d5d2c04d9002ac9--
