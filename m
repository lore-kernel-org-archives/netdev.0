From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] Revert "bridge: only expire the mdb entry when
	query is received"
Date: Tue, 22 Oct 2013 09:10:14 -0400
Message-ID: <CAGCdqXG0V+2vHVg6NPXocN6ZLVGOT8e16fEt-TXx5=Rh0tFmiw@mail.gmail.com>
References: <1382223537-10844-1-git-send-email-linus.luessing@web.de>
	<20131021.184509.1933008514161772000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a11c347700bd2a504e9541f13
Cc: amwang@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>, linus.luessing@web.de
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20131021.184509.1933008514161772000.davem@davemloft.net>
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

--001a11c347700bd2a504e9541f13
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 21, 2013 at 6:45 PM, David Miller <davem@davemloft.net> wrote:

> From: Linus L=FCssing <linus.luessing@web.de>
> Date: Sun, 20 Oct 2013 00:58:57 +0200
>
> > While this commit was a good attempt to fix issues occuring when no
> > multicast querier is present, this commit still has two more issues:
> >
> > 1) There are cases where mdb entries do not expire even if there is a
> > querier present. The bridge will unnecessarily continue flooding
> > multicast packets on the according ports.
> >
> > 2) Never removing an mdb entry could be exploited for a Denial of
> > Service by an attacker on the local link, slowly, but steadily eating u=
p
> > all memory.
> >
> > Actually, this commit became obsolete with
> > "bridge: disable snooping if there is no querier" (b00589af3b)
> > which included fixes for a few more cases.
> >
> > Therefore reverting the following commits (the commit stated in the
> > commit message plus three of its follow up fixes):
> >
> > ---
> > Revert "bridge: update mdb expiration timer upon reports."
> > This reverts commit f144febd93d5ee534fdf23505ab091b2b9088edc.
> > Revert "bridge: do not call setup_timer() multiple times"
> > This reverts commit 1faabf2aab1fdaa1ace4e8c829d1b9cf7bfec2f1.
> > Revert "bridge: fix some kernel warning in multicast timer"
> > This reverts commit c7e8e8a8f7a70b343ca1e0f90a31e35ab2d16de1.
> > Revert "bridge: only expire the mdb entry when query is received"
> > This reverts commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b.
> > ---
>
> Cong, and other bridge folks, please review this revert.
>

Makes sense and make the implementation better follow the spec.
Looks like the issues seen before are resolved by the revert.

Reviewed-by: Vlad Yasevich <vyasevich@gmail.com>

--001a11c347700bd2a504e9541f13
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra">On Mon, Oct 21, 2013 at 6:45 PM=
, David Miller <span dir=3D"ltr">&lt;<a href=3D"mailto:davem@davemloft.net"=
 target=3D"_blank">davem@davemloft.net</a>&gt;</span> wrote:<br><div class=
=3D"gmail_quote">
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">From: Linus L=FCssing &lt;<a href=3D"mailto:linus.luessing=
@web.de">linus.luessing@web.de</a>&gt;<br>

Date: Sun, 20 Oct 2013 00:58:57 +0200<br>
<br>
&gt; While this commit was a good attempt to fix issues occuring when no<br=
>
&gt; multicast querier is present, this commit still has two more issues:<b=
r>
&gt;<br>
&gt; 1) There are cases where mdb entries do not expire even if there is a<=
br>
&gt; querier present. The bridge will unnecessarily continue flooding<br>
&gt; multicast packets on the according ports.<br>
&gt;<br>
&gt; 2) Never removing an mdb entry could be exploited for a Denial of<br>
&gt; Service by an attacker on the local link, slowly, but steadily eating =
up<br>
&gt; all memory.<br>
&gt;<br>
&gt; Actually, this commit became obsolete with<br>
&gt; &quot;bridge: disable snooping if there is no querier&quot; (b00589af3=
b)<br>
&gt; which included fixes for a few more cases.<br>
&gt;<br>
&gt; Therefore reverting the following commits (the commit stated in the<br=
>
&gt; commit message plus three of its follow up fixes):<br>
&gt;<br>
&gt; ---<br>
&gt; Revert &quot;bridge: update mdb expiration timer upon reports.&quot;<b=
r>
&gt; This reverts commit f144febd93d5ee534fdf23505ab091b2b9088edc.<br>
&gt; Revert &quot;bridge: do not call setup_timer() multiple times&quot;<br=
>
&gt; This reverts commit 1faabf2aab1fdaa1ace4e8c829d1b9cf7bfec2f1.<br>
&gt; Revert &quot;bridge: fix some kernel warning in multicast timer&quot;<=
br>
&gt; This reverts commit c7e8e8a8f7a70b343ca1e0f90a31e35ab2d16de1.<br>
&gt; Revert &quot;bridge: only expire the mdb entry when query is received&=
quot;<br>
&gt; This reverts commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b.<br>
&gt; ---<br>
<br>
Cong, and other bridge folks, please review this revert.<br></blockquote><d=
iv><br></div><div>Makes sense and make the implementation better follow the=
 spec.</div><div>Looks like the issues seen before are resolved by the reve=
rt.</div>
<div><br></div>Reviewed-by: Vlad Yasevich &lt;<a href=3D"mailto:vyasevich@g=
mail.com">vyasevich@gmail.com</a>&gt;<div class=3D"gmail_extra"><br></div><=
div>=A0</div></div></div></div>

--001a11c347700bd2a504e9541f13--
