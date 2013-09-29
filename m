From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Subject: Re: [PATCH v2.40 3/7] ofp-actions: Add
	OFPUTIL_OFPAT13_PUSH_MPLS
Date: Sun, 29 Sep 2013 15:07:21 +1300
Message-ID: <CAOftzPgVAOv4zXU8qU-ibf2zK4URwtWo+0NnDzUG4S1qJ3MvwA@mail.gmail.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
	<1380241116-7661-4-git-send-email-horms@verge.net.au>
	<20130927193010.GB17506@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0785375373=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130927193010.GB17506-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

--===============0785375373==
Content-Type: multipart/alternative; boundary=e89a8ff24d9d40f24a04e77c2faf

--e89a8ff24d9d40f24a04e77c2faf
Content-Type: text/plain; charset=ISO-8859-1

I recall having a bit of discussion regarding this approach and whether to
change it, but I don't recall the issues around this.

Your suggestion sounds sane. What are your thoughts, Simon?


On Sat, Sep 28, 2013 at 7:30 AM, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> On Fri, Sep 27, 2013 at 09:18:32AM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> >
> > This patch adds a new compatibility enum for use with MPLS, so that the
> > differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
> > ofproto-dpif-xlate.
>
> It seems a little awkward to me to do this via a new OFPACT_, mostly
> because there isn't currently any distinction between OF1.1 and OF1.3 in
> terms of OFPACT_ definitions.  Did you consider adding a new field to
> struct ofpact_push_mpls that would say whether the label should be added
> before or after a VLAN tag?
>

--e89a8ff24d9d40f24a04e77c2faf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I recall having a bit of discussion regarding this approac=
h and whether to change it, but I don&#39;t recall the issues around this.<=
div><br></div><div>Your suggestion sounds sane. What are your thoughts, Sim=
on?</div>

</div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Sat,=
 Sep 28, 2013 at 7:30 AM, Ben Pfaff <span dir=3D"ltr">&lt;<a href=3D"mailto=
:blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" target=3D"_blank">blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org</a>&gt;</span> wrote:<br>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">

<div class=3D"im">On Fri, Sep 27, 2013 at 09:18:32AM +0900, Simon Horman wr=
ote:<br>
&gt; From: Joe Stringer &lt;<a href=3D"mailto:joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org">joe-Q1GJJQv1iO4@public.gmane.org=
.nz</a>&gt;<br>
&gt;<br>
&gt; This patch adds a new compatibility enum for use with MPLS, so that th=
e<br>
&gt; differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in=
<br>
&gt; ofproto-dpif-xlate.<br>
<br>
</div>It seems a little awkward to me to do this via a new OFPACT_, mostly<=
br>
because there isn&#39;t currently any distinction between OF1.1 and OF1.3 i=
n<br>
terms of OFPACT_ definitions. =A0Did you consider adding a new field to<br>
struct ofpact_push_mpls that would say whether the label should be added<br=
>
before or after a VLAN tag?<br>
</blockquote></div><br></div>

--e89a8ff24d9d40f24a04e77c2faf--

--===============0785375373==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0785375373==--
