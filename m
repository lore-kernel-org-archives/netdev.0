From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.4.0
Date: Mon, 11 Jan 2016 08:50:14 -0800
Message-ID: <20160111085014.18b734e4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Release of iproute2 for Linux 4.4 (Blurry Fish Butt)

Update to iproute2 utility to support new features in Linux 4.4.
Lots of new features including: support for VRF; lightweight tunnels;
and more changes to BPF.


Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.4.0.tar=
=2Egz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

I will be merging net-next to master soon.

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

---
Aaro Koskinen (1):
      misc/Makefile: use PKG_CONFIG

Daniel Borkmann (2):
      f_bpf: allow for optional classid and add flags
      m_bpf: don't require default opcode on ebpf actions

David Ahern (5):
      ip route: Add RTM_F_LOOKUP_TABLE flag and show table id
      ip neigh: Add support for filtering dumps by master device
      ip neigh: Add ifindex to request when filtering dumps by device
      Add support for rt_tables.d
      vrf: Add support for table names

Hannes Frederic Sowa (1):
      iproute: print addrgenmode stable_secret and fallback otherwise

Jamal Hadi Salim (1):
      tc: flower no need to specify the ethertype

John W. Linville (1):
      geneve: add support for IPv6 link partners

Julien Floret (1):
      tc: fix compilation with old gcc (< 4.6)

Konstantin Khlebnikov (1):
      ip neigh: device is optional for proxy entries

Konstantin Shemyak (1):
      ip_tunnel: determine tunnel address family from the tunnel type

Neil Horman (1):
      iproute2: Ignore EADDRNOTAVAIL errors during address flush operat=
ion

Nicolas Dichtel (1):
      libnetlink: don't confuse variables in rtnl_talk()

Paolo Abeni (4):
      lwtunnel: fix argument parsing
      vxlan: add support for collect metadata flag
      gre: add support for collect metadata flag
      lwtunnel: implement support for ip6 encap

Phil Sutter (34):
      ip{, 6}tunnel: get rid of extraneous whitespace when printing
      ip/tunnel: introduce tnl_parse_key()
      ip{, 6}tunnel: unify behaviour if physical device is not found
      iptunnel: use ll_name_to_index() for physical interface lookup
      ip{,6}tunnel: align do_tunnels_list() a bit
      ip6tunnel: print local/remote addresses like iptunnel does
      ip6tunnel: fix coding style: no newline between brace and else
      iptunnel: share common code when setting tunnel mode
      iptunnel: simplify parsing TTL, allow 'hlim' as identifier
      iptunnel: share common code when determining the default interfac=
e name
      iptunnel: sanitize copying tunnel name
      ip{,6}tunnel: put spaces around non-unary operators
      ip_common.h header cleanup
      lnstat: describe -s option in help output
      lnstat: fix header displaying mechanism
      bridge.8: document fdb replace command
      ipaddress: simplify ipaddr_flush()
      libnetlink: introduce nc_flags
      ipaddress: fix ipaddr_flush for Linux >=3D 3.1
      ipaddress: drop unnecessary check in ipaddr_list_flush_or_save()
      iptoken: simplify iptoken_list a bit
      iproute: restrict hoplimit values to be in range [0; 255]
      bridge.8: minor formatting cleanup
      lnstat: review lnstat_update()
      ss: reduce max indentation level in init_service_resolver()
      ss: review is_ephemeral()
      get rid of remaining -Wunused-result warnings
      get rid of unnecessary fgets() buffer size limitation
      route: ignore RTAX_HOPLIMIT of value -1
      tc.8: Fix reference to tc-tcindex.8
      route: Fix printing of locked entries
      ip{,6}tunnel: have a shared stats parser/printer
      iptunnel: Fix compile error in ip/tunnel.c
      tc: m_connmark: Fix help text

Richard Alpe (2):
      tipc: fix help text spelling error in node.c
      tipc: add peer remove functionality

Roopa Prabhu (3):
      lwtunnel: Add encapsulation support to ip route
      ip-route man: add usage and description for lwtunnel encap attrib=
utes
      iplink: replace exit with return

Stephen Hemminger (14):
      update kernel headers to 4.3 net-next
      update kernel headers for net-next
      add tunnel header files from net-next uapi
      update bpf kernel header
      add new IFLA_VF_TRUST netlink attribute
      man8: scrub trailing whitespace
      misc: remove extra blank line
      update kernel headers to 4.4-rc1
      rt_names: style cleanup
      iptunnel: cleanup code
      ip: fix format string when reading statistics
      man: fix whatis for fq
      Revert "tipc: add peer remove functionality"
      v4.4.0

Tom Herbert (2):
      vxlan: Add support for remote checksum offload
      ila: Add support for ILA lwtunnels

Ville Skytt=C3=A4 (2):
      man: Syntax and warning fixes
      man: Spelling fixes
