From: Zhi Yong Wu <zwu.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL v3] Open vSwitch
Date: Mon, 5 Dec 2011 11:32:21 +0800
Message-ID: <CAEH94LiXLAKFWkDG5VBo80rFTfXMnxn1=2aEb5qOieBUnoYRyA@mail.gmail.com>
References: <1322937531-8071-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322937531-8071-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Although this series of patchset is a bit large, therefore their codes
aren't directly pasted here, but if anyone find some issues in the
codes, how will we point out them?

On Sun, Dec 4, 2011 at 2:38 AM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> This series of patches proposes the Open vSwitch kernel components for
> upstream. =A0Open vSwitch has existed as a separate project for several
> years and we now believe it to be mature enough for inclusion. =A0The
> actual functionality is described more fully in the commit that adds
> the kernel code.
>
> The following changes since commit 340e8dc1fb4032b6c8334c9bff20b2aec42ecf=
d8:
>
> =A0atm: clip: Remove code commented out since eternity. (2011-12-02 14:27=
:11 -0500)
>
> are available in the git repository at:
> =A0git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fo=
r-upstream
>
> Jesse Gross (3):
> =A0 =A0 =A0genetlink: Add rcu_dereference_genl and genl_dereference.
> =A0 =A0 =A0ipv6: Add fragment reporting to ipv6_skip_exthdr().
> =A0 =A0 =A0net: Add Open vSwitch kernel components.
>
> Pravin B Shelar (3):
> =A0 =A0 =A0genetlink: Add genl_notify()
> =A0 =A0 =A0genetlink: Add lockdep_genl_is_held().
> =A0 =A0 =A0vlan: Move vlan_set_encap_proto() to vlan header file
>
> =A0Documentation/networking/00-INDEX =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0Documentation/networking/openvswitch.txt | =A0195 +++
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A08 +
> =A0include/linux/genetlink.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 24 +
> =A0include/linux/if_vlan.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 34 +
> =A0include/linux/openvswitch.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0452 +++++++
> =A0include/net/genetlink.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0include/net/ipv6.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =
=A02 +-
> =A0net/8021q/vlan_core.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 33 -
> =A0net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A01 +
> =A0net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A01 +
> =A0net/bridge/br_multicast.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +-
> =A0net/bridge/netfilter/ebt_ip6.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/bridge/netfilter/ebt_log.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/ipv6/exthdrs_core.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +-
> =A0net/ipv6/icmp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A07 +-
> =A0net/ipv6/ip6_input.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
3 +-
> =A0net/ipv6/ip6_output.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
3 +-
> =A0net/ipv6/netfilter/ip6t_REJECT.c =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/netfilter/ipset/ip_set_getport.c =A0 =A0 | =A0 =A04 +-
> =A0net/netfilter/xt_AUDIT.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/netfilter/xt_TCPMSS.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +-
> =A0net/netfilter/xt_TCPOPTSTRIP.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/netfilter/xt_hashlimit.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0net/netfilter/xt_socket.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0net/netlink/genetlink.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 +
> =A0net/openvswitch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 28 +
> =A0net/openvswitch/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 14 +
> =A0net/openvswitch/actions.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0415 ++++=
+++
> =A0net/openvswitch/datapath.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 1912 ++++++++=
++++++++++++++++++++++
> =A0net/openvswitch/datapath.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0125 ++
> =A0net/openvswitch/dp_notify.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 66 +
> =A0net/openvswitch/flow.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 1346 ++++=
+++++++++++++++++
> =A0net/openvswitch/flow.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0199 ++=
++
> =A0net/openvswitch/vport-internal_dev.c =A0 =A0 | =A0241 ++++
> =A0net/openvswitch/vport-internal_dev.h =A0 =A0 | =A0 28 +
> =A0net/openvswitch/vport-netdev.c =A0 =A0 =A0 =A0 =A0 | =A0198 +++
> =A0net/openvswitch/vport-netdev.h =A0 =A0 =A0 =A0 =A0 | =A0 42 +
> =A0net/openvswitch/vport.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0396 ++=
++++
> =A0net/openvswitch/vport.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0205 ++=
++
> =A0security/lsm_audit.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
3 +-
> =A0security/selinux/hooks.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A042 files changed, 6000 insertions(+), 52 deletions(-)
> =A0create mode 100644 Documentation/networking/openvswitch.txt
> =A0create mode 100644 include/linux/openvswitch.h
> =A0create mode 100644 net/openvswitch/Kconfig
> =A0create mode 100644 net/openvswitch/Makefile
> =A0create mode 100644 net/openvswitch/actions.c
> =A0create mode 100644 net/openvswitch/datapath.c
> =A0create mode 100644 net/openvswitch/datapath.h
> =A0create mode 100644 net/openvswitch/dp_notify.c
> =A0create mode 100644 net/openvswitch/flow.c
> =A0create mode 100644 net/openvswitch/flow.h
> =A0create mode 100644 net/openvswitch/vport-internal_dev.c
> =A0create mode 100644 net/openvswitch/vport-internal_dev.h
> =A0create mode 100644 net/openvswitch/vport-netdev.c
> =A0create mode 100644 net/openvswitch/vport-netdev.h
> =A0create mode 100644 net/openvswitch/vport.c
> =A0create mode 100644 net/openvswitch/vport.h
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev



-- =

Regards,

Zhi Yong Wu
