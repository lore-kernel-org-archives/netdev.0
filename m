From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory pressure
 controls
Date: Tue, 13 Dec 2011 14:49:11 +0100
Message-ID: <4EE757D7.6060006@uclouvain.be>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com> <20111212.190734.1967808916779299221.davem@davemloft.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org,
 paul@paulmenage.org, lizf@cn.fujitsu.com,
 kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com,
 gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org,
 kirill@shutemov.name, avagin@parallels.com, devel@openvz.org,
 eric.dumazet@gmail.com, cgroups@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111212.190734.1967808916779299221.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/13/2011 01:07 AM, David Miller wrote:
> From: Glauber Costa <glommer@parallels.com>
> Date: Mon, 12 Dec 2011 11:47:00 +0400
>=20
>> This series fixes all the few comments raised in the last round,
>> and seem to have acquired consensus from the memcg side.
>>
>> Dave, do you think it is acceptable now from the networking PoV?
>> In case positive, would you prefer merging this trough your tree,
>> or acking this so a cgroup maintainer can do it?
>=20
> All applied to net-next, thanks.

now there are plenty of compiler-warnings when CONFIG_CGROUPS is not set:

In file included from include/linux/tcp.h:211:0,
                 from include/linux/ipv6.h:221,
                 from include/net/ip_vs.h:23,
                 from kernel/sysctl_binary.c:6:
include/net/sock.h:67:57: warning: =E2=80=98struct cgroup_subsys=E2=80=99=
 declared
inside parameter list [enabled by default]
include/net/sock.h:67:57: warning: its scope is only this definition or
declaration, which is probably not what you want [enabled by default]
include/net/sock.h:67:57: warning: =E2=80=98struct cgroup=E2=80=99 declar=
ed inside
parameter list [enabled by default]
include/net/sock.h:68:61: warning: =E2=80=98struct cgroup_subsys=E2=80=99=
 declared
inside parameter list [enabled by default]
include/net/sock.h:68:61: warning: =E2=80=98struct cgroup=E2=80=99 declar=
ed inside
parameter list [enabled by default]


Because struct cgroup is only declared if CONFIG_CGROUPS is enabled.
(cfr. linux/cgroup.h)


Christoph

--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
