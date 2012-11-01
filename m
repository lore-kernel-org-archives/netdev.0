From: =?GB2312?B?taXOwA==?= <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Thu, 1 Nov 2012 22:44:44 +0800
Message-ID: <CAPYxyx+BVdtoo9-uZje7b4BOXmHBx+yg1Ac27Qe1oO_kptj-KA@mail.gmail.com>
References: <50910A04.5000003@gmail.com>
	<0000013ab7e86f8a-4adb8b81-19be-4264-96f1-924aaf3819f2-000000@email.amazonses.com>
	<509249C7.3080000@gmail.com>
	<0000013abc646055-30441bd6-241f-436a-a356-9cd462da66ce-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0771321823=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0000013abc646055-30441bd6-241f-436a-a356-9cd462da66ce-000000-p/GC64/jrecnJqMo6gzdpkEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0771321823==
Content-Type: multipart/alternative; boundary=e89a8fb2062e60cf0804cd700f9c

--e89a8fb2062e60cf0804cd700f9c
Content-Type: text/plain; charset=ISO-8859-1

2012/11/1 Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

>
> > In addition, following usage of per_cpu_ptr can be replaced by
> this_cpu_read.
> >
> > cpu=get_cpu()
> > ....
> > *per_cpu_ptr(p,cpu)
> > ....
> > ....
> > put_cpu()
>
> Right.
>
>
Thanks very much,
I  will resubmit new patchset.

--e89a8fb2062e60cf0804cd700f9c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

2012/11/1 Christoph Lameter <span dir=3D"ltr">&lt;<a href=3D"mailto:cl@linu=
x.com" target=3D"_blank">cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org</a>&gt;</span><br><div class=3D"gmail=
_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex">
<div class=3D"im"><br></div><div class=3D"im">
&gt; In addition, following usage of per_cpu_ptr can be replaced by this_cp=
u_read.<br>
&gt;<br>
&gt; cpu=3Dget_cpu()<br>
&gt; ....<br>
&gt; *per_cpu_ptr(p,cpu)<br>
&gt; ....<br>
&gt; ....<br>
&gt; put_cpu()<br>
<br>
</div>Right.<br>
<br>
</blockquote></div><br><div>Thanks very much,</div><div>I =A0will resubmit =
new patchset.</div><div><br></div>

--e89a8fb2062e60cf0804cd700f9c--

--===============0771321823==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0771321823==--
