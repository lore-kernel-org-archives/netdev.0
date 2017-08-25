From: Jeffrey Vander Stoep via Selinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 17:56:47 +0000
Message-ID: <CABXk95ATb_AFk+4GX9Xw+HEU6No8irb0mOoLE9O4EBuLAgA-1w@mail.gmail.com>
Reply-To: Jeffrey Vander Stoep <jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="001a114881aae0e78a055797ab18"
To: Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, SELinux <Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

--001a114881aae0e78a055797ab18
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I=E2=80=99d like to get your thoughts on adding LSM permission checks on BP=
F
objects.

By default, the ability to create and use eBPF maps/programs requires
CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access to
bpf() functions. This seems like poor granularity. [2]

Like files and sockets, eBPF maps and programs can be passed between
processes by FD and have a number of functions that map cleanly to
permissions.

Let me know what you think. Are there simpler alternative approaches that
we haven=E2=80=99t considered?

Thanks!
Jeff

[1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
[2] We are considering eBPF for network filtering by netd. Giving netd
CAP_SYS_ADMIN would considerably increase netd=E2=80=99s privileges. Altern=
atively
allowing all processes permission to use bpf() goes against the principle
of least privilege exposing a lot of kernel attack surface to processes
that do not actually need it.

--001a114881aae0e78a055797ab18
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>I=E2=80=99d like to get your thoughts on adding LSM p=
ermission checks on BPF objects.<br></div><div><br></div><div>By default, t=
he ability to create and use eBPF maps/programs requires CAP_SYS_ADMIN [1].=
 Alternatively, all processes can be granted access to bpf() functions. Thi=
s seems like poor granularity. [2]</div><div><br></div><div>Like files and =
sockets, eBPF maps and programs can be passed between processes by FD and h=
ave a number of functions that map cleanly to permissions.</div><div><br></=
div><div>Let me know what you think. Are there simpler alternative approach=
es that we haven=E2=80=99t considered?</div><div><br></div><div>Thanks!</di=
v><div>Jeff=C2=A0</div><div><br></div><div>[1] <a href=3D"http://man7.org/l=
inux/man-pages/man2/bpf.2.html">http://man7.org/linux/man-pages/man2/bpf.2.=
html</a> NOTES section</div><div>[2] We are considering eBPF for network fi=
ltering by netd. Giving netd CAP_SYS_ADMIN would considerably increase netd=
=E2=80=99s privileges. Alternatively allowing all processes permission to u=
se bpf() goes against the principle of least privilege exposing a lot of ke=
rnel attack surface to processes that do not actually need it.</div></div>

--001a114881aae0e78a055797ab18--
