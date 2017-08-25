From: Jeffrey Vander Stoep via Selinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 18:03:10 +0000
Message-ID: <CABXk95BsEFMScY7mzT-JwaRtFGQoi-v5yebeMuavhPWWijUeDQ@mail.gmail.com>
References: <CABXk95ATb_AFk+4GX9Xw+HEU6No8irb0mOoLE9O4EBuLAgA-1w@mail.gmail.com>
Reply-To: Jeffrey Vander Stoep <jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="001a11465ab4a8985b055797c2c1"
To: Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, SELinux <Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
In-Reply-To: <CABXk95ATb_AFk+4GX9Xw+HEU6No8irb0mOoLE9O4EBuLAgA-1w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

--001a11465ab4a8985b055797c2c1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Disregard this email. Re-sending in plain-text mode to prevent rejection by
netdev list.

On Fri, Aug 25, 2017 at 10:56 AM Jeffrey Vander Stoep <jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
wrote:

> I=E2=80=99d like to get your thoughts on adding LSM permission checks on =
BPF
> objects.
>
> By default, the ability to create and use eBPF maps/programs requires
> CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access to
> bpf() functions. This seems like poor granularity. [2]
>
> Like files and sockets, eBPF maps and programs can be passed between
> processes by FD and have a number of functions that map cleanly to
> permissions.
>
> Let me know what you think. Are there simpler alternative approaches that
> we haven=E2=80=99t considered?
>
> Thanks!
> Jeff
>
> [1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
> [2] We are considering eBPF for network filtering by netd. Giving netd
> CAP_SYS_ADMIN would considerably increase netd=E2=80=99s privileges. Alte=
rnatively
> allowing all processes permission to use bpf() goes against the principle
> of least privilege exposing a lot of kernel attack surface to processes
> that do not actually need it.
>

--001a11465ab4a8985b055797c2c1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Disregard this email. Re-sending in plain-text mode to pre=
vent rejection by netdev list.<br><br><div class=3D"gmail_quote"><div dir=
=3D"ltr">On Fri, Aug 25, 2017 at 10:56 AM Jeffrey Vander Stoep &lt;<a href=
=3D"mailto:jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org">jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br></div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex"><div dir=3D"ltr"><div>I=E2=80=99d like to get you=
r thoughts on adding LSM permission checks on BPF objects.<br></div><div><b=
r></div><div>By default, the ability to create and use eBPF maps/programs r=
equires CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted acce=
ss to bpf() functions. This seems like poor granularity. [2]</div><div><br>=
</div><div>Like files and sockets, eBPF maps and programs can be passed bet=
ween processes by FD and have a number of functions that map cleanly to per=
missions.</div><div><br></div><div>Let me know what you think. Are there si=
mpler alternative approaches that we haven=E2=80=99t considered?</div><div>=
<br></div><div>Thanks!</div><div>Jeff=C2=A0</div><div><br></div><div>[1] <a=
 href=3D"http://man7.org/linux/man-pages/man2/bpf.2.html" target=3D"_blank"=
>http://man7.org/linux/man-pages/man2/bpf.2.html</a> NOTES section</div><di=
v>[2] We are considering eBPF for network filtering by netd. Giving netd CA=
P_SYS_ADMIN would considerably increase netd=E2=80=99s privileges. Alternat=
ively allowing all processes permission to use bpf() goes against the princ=
iple of least privilege exposing a lot of kernel attack surface to processe=
s that do not actually need it.</div></div></blockquote></div></div>

--001a11465ab4a8985b055797c2c1--
