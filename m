From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port
	shouldn't learn
Date: Mon, 25 May 2015 13:35:20 +0200
Message-ID: <CABQ03vEiLYWJ+jAttW1XU5EZOjFSRn_dRXyNiE_+hOcmXoQSAQ@mail.gmail.com>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150524.225902.2017701461230237731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=90e6ba6e84609f06bd0516e6678b
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Wilson Kok <wkok@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150524.225902.2017701461230237731.davem@davemloft.net>
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

--90e6ba6e84609f06bd0516e6678b
Content-Type: text/plain; charset=UTF-8

On Mon, May 25, 2015 at 4:59 AM, David Miller <davem@davemloft.net> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Thu, 21 May 2015 03:42:57 -0700
>
> > From: Wilson Kok <wkok@cumulusnetworks.com>
> >
> > Check in fdb_add_entry() if the source port should learn, similar
> > check is used in br_fdb_update.
> > Note that new fdb entries which are added manually or
> > as local ones are still permitted.
> > This patch has been tested by running traffic via a bridge port and
> > switching the port's state, also by manually adding/removing entries
> > from the bridge's fdb.
> >
> > Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> > Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > ---
> > Nik: Maybe it'd be better if we returned an error even though it
> >      doesn't look necessary. I'm open to suggestions.
>
> If you don't return an error, then rtnetlink.c is going to emit a
> NEWNEIGH netlink message.  I seriously doubt we want that to happen.
>

Thanks Dave, I was afraid I've missed something like that. I'll re-spin,
test
and post a v2.

Nik

--90e6ba6e84609f06bd0516e6678b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Mon, May 25, 2015 at 4:59 AM, David Miller <span dir=3D=
"ltr">&lt;<a href=3D"mailto:davem@davemloft.net" target=3D"_blank">davem@da=
vemloft.net</a>&gt;</span> wrote:<br><div class=3D"gmail_extra"><div class=
=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">From: Nikolay Aleksandrov &=
lt;<a href=3D"mailto:nikolay@cumulusnetworks.com">nikolay@cumulusnetworks.c=
om</a>&gt;<br>
Date: Thu, 21 May 2015 03:42:57 -0700<br>
<span class=3D""><br>
&gt; From: Wilson Kok &lt;<a href=3D"mailto:wkok@cumulusnetworks.com">wkok@=
cumulusnetworks.com</a>&gt;<br>
&gt;<br>
&gt; Check in fdb_add_entry() if the source port should learn, similar<br>
&gt; check is used in br_fdb_update.<br>
&gt; Note that new fdb entries which are added manually or<br>
&gt; as local ones are still permitted.<br>
&gt; This patch has been tested by running traffic via a bridge port and<br=
>
&gt; switching the port&#39;s state, also by manually adding/removing entri=
es<br>
&gt; from the bridge&#39;s fdb.<br>
&gt;<br>
&gt; Signed-off-by: Wilson Kok &lt;<a href=3D"mailto:wkok@cumulusnetworks.c=
om">wkok@cumulusnetworks.com</a>&gt;<br>
&gt; Signed-off-by: Nikolay Aleksandrov &lt;<a href=3D"mailto:nikolay@cumul=
usnetworks.com">nikolay@cumulusnetworks.com</a>&gt;<br>
&gt; ---<br>
&gt; Nik: Maybe it&#39;d be better if we returned an error even though it<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 doesn&#39;t look necessary. I&#39;m open to sugges=
tions.<br>
<br>
</span>If you don&#39;t return an error, then rtnetlink.c is going to emit =
a<br>
NEWNEIGH netlink message.=C2=A0 I seriously doubt we want that to happen.<b=
r>
</blockquote></div><br></div><div class=3D"gmail_extra">Thanks Dave, I was =
afraid I&#39;ve missed something like that. I&#39;ll re-spin, test<br></div=
><div class=3D"gmail_extra">and post a v2.<br><br></div><div class=3D"gmail=
_extra">Nik<br></div></div>

--90e6ba6e84609f06bd0516e6678b--
