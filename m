From: Nicholas Bastin <nick.bastin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ovs-discuss] kernel panic receiving flooded VXLAN traffic with
	OVS
Date: Mon, 8 Dec 2014 11:14:41 -1000
Message-ID: <CADmMkWcj9RmVHy1DH1ULUVrVTdt958qaTt6edW6WQA0mZ66acA@mail.gmail.com>
References: <19014.1415325508@famine> <8549.1417657547@famine>
 <CAEP_g=_mfSCH1250ezx_h8_yM_4FzsYcsS6EnGi99AFoWO_MKw@mail.gmail.com>
 <CADmMkWdGhw3Rn3gMEtAV8ESZB-k+uAK=Ed=LwsShKOtyHdJS_g@mail.gmail.com>
 <CAEP_g=86QKL_Oxxj0mo8CZs8+fyBZuYw2fQTMGow_bSJbk+8AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7567001436236880824=="
Cc: "discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=86QKL_Oxxj0mo8CZs8+fyBZuYw2fQTMGow_bSJbk+8AQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/discuss>,
 <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/discuss>
List-Post: <mailto:discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/discuss>,
 <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "discuss" <discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============7567001436236880824==
Content-Type: multipart/alternative; boundary=047d7bdc81cc3c0f6c0509baeadc

--047d7bdc81cc3c0f6c0509baeadc
Content-Type: text/plain; charset=UTF-8

On Mon, Dec 8, 2014 at 7:33 AM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> If you look at the implementation of GRO/TSO, I think you will see
> that it does in fact faithfully reconstruct the original message and
> path MTU discovery is preserved. On Linux systems, GRO is enabled by
> default for all workloads - including those that do not result in
> local termination such as bridging.


I will go back and test this again (it's been a while - we just run with
all offloads turned off by default now).  When we were having problems with
this we would find segmented TCP flows getting reassembled along the path
and then output with the local egress MTU (which was considerably larger
than that at the end stations), resulting in performance-crushing IP
fragmentation later in the path.

--
Nick

--047d7bdc81cc3c0f6c0509baeadc
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On M=
on, Dec 8, 2014 at 7:33 AM, Jesse Gross <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" target=3D"_blank">jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"=
h5"><span style=3D"color:rgb(34,34,34)">If you look at the implementation o=
f GRO/TSO, I think you will see</span><br></div></div>
that it does in fact faithfully reconstruct the original message and<br>
path MTU discovery is preserved. On Linux systems, GRO is enabled by<br>
default for all workloads - including those that do not result in<br>
local termination such as bridging.</blockquote><div><br></div><div>I will =
go back and test this again (it&#39;s been a while - we just run with all o=
ffloads turned off by default now).=C2=A0 When we were having problems with=
 this we would find segmented TCP flows getting reassembled along the path =
and then output with the local egress MTU (which was considerably larger th=
an that at the end stations), resulting in performance-crushing IP fragment=
ation later in the path.</div><div><br></div><div>--</div><div>Nick=C2=A0</=
div></div></div></div>

--047d7bdc81cc3c0f6c0509baeadc--

--===============7567001436236880824==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGlzY3VzcyBt
YWlsaW5nIGxpc3QKZGlzY3Vzc0BvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rpc2N1c3MK

--===============7567001436236880824==--
