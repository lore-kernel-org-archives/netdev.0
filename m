From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iprotue2 v3.11.0
Date: Tue, 3 Sep 2013 08:32:18 -0700
Message-ID: <20130903083218.6dcb67a7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Iproute2 tools for Workgroups (3.11) is not available.
It has the usual set of fixes and support for the new features
in 3.11. Thank for all the contributions.

I will merge in the next-3.11 branch. After that
if you have been sitting on changes to iproute2 that are in
net-next for 3.12 merge window, please submit them now.

Iproute2 package is available at:
  http://kernel.org/pub/linux/utils/net/iproute2/iproute2-3.10.0.tar.gz

You can download the source from:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

---

Adam Borowski (1):
      ip: fix build failure if time_t is not long int

Alexander Duyck (1):
      iproute2: act_ipt fix xtables breakage on older versions.

Amerigo Wang (1):
      iptunnel: check SIT_ISATAP flag only for SIT tunnel

Andreas Henriksson (1):
      iproute2: fix build failure on sparc due to -Wformat and tv_usec

Andrey Vagin (5):
      ip: set the close-on-exec flag for descriptors
      ss: handle socket diag request in a separate function
      ss: create a function to print info about netlink sockets
      ss: show destination address for netlink sockets
      ss: Get netlink sockets info via sock-diag (v2)

Atzm Watanabe (1):
      vxlan: Allow setting destination to unicast address.

Cong Wang (1):
      add quickack option to ip route

Daniel Borkmann (1):
      ip: ipv6: add tokenized interface identifier support

David L Stevens (1):
      iproute2: support NTF_ROUTER flag in VXLAN fdb entries

David Stevens (1):
      iproute2: generalize VXLAN forwarding tables

Eric Dumazet (4):
      ss: add fastopen support
      htb: report overhead attribute
      get_rate: detect 32bit overflows
      ss: add more TCP_INFO components

Jesper Dangaard Brouer (1):
      linklayer interface between kernel and tc/userspace

John Fastabend (1):
      iproute2: bridge: fix 'bridge link' setlink/getlink parsing

JunweiZhang (1):
      ipbatch: fix use of 'ip netns exec'

Kamil Rytarowski (1):
      iproute2 patch against GCC 4.8.0

Lutz Jaenicke (1):
      macvlan: fix typo in macvlan_print_opt()

Martin Schwenke (1):
      ip: Add label option to ip monitor

Nicolas Dichtel (8):
      ip: add missing help about mode argument
      ip/xfrm: all to set flag XFRM_SA_XFLAG_DONT_ENCAP_DSCP
      ipnetconf: by default dump all entries
      ss: allow to retrieve AF_PACKET info via netlink
      man: describe --bpf option of ss
      ipadress: fix display of IPv6 peer address
      ip: allow to specify mode for sit tunnels
      ipnetns: fix ip batch mode when using 'netns exec'

Patric McHardy (1):
      ip: iplink_vlan: add 802.1ad support

Pavel Emelyanov (1):
      ss: Show inet and unix sockets' shutdown state

Rami Rosen (1):
      ss: replace bfp with bpf in usage().

Richard Godbee (3):
      iproute2: iproute.c: fix usage() spacing problems
      iproute2: spelling: noptmudisc -> nopmtudisc
      iproute2: ip-route.8.in: minor fixes

Rony Efraim (1):
      Add VF link state control

Sriram Narasimhan (1):
      iptuntap: allow creation of multi-queue tun/tap device

Stefan Tomanek (1):
      ip link: fix display of interface groups

Stephen Hemminger (21):
      Update headers to 3.10
      Add vxlan destination port option
      vxlan: nag user to set port value
      add BPF header files
      vxlan: remove dstport option
      man: get rid of useless reference to GNU style options
      htb: fix indentation
      update to 3.10-net-next headers
      netns: follow return value conventions of the rest of the code
      ip: add batch mode to man page
      Make tc and ip batch mode consistent
      v3.10.0
      Update to 3.11-rc1 kernel headers
      Remove -Werror
      cleanup help message
      Fix spelling errors
      More minor spelling fixes
      tc: allow qdisc without options
      add ability to filter neighbour discovery by protocol
      Update kernel headers to 3.11
      v3.11.0

Thomas Egerer (1):
      ip/xfrm: Fix potential SIGSEGV when printing extra flags

Thomas Richter (3):
      iproute2 vxlan documentation update for bridge command
      iproute2 vxlan documentation update for ip command
      iproute vxlan add support for fdb replace command

esr@thyrsus.com (4):
      First set of manpage markup fixes
      tc-stab.8: Fix synopsis errors, an invalid escape, and incorrect English usge.
      In tc-ematch.8, remove no-op .ti requests to prevent translation warnings
      ip-rule.8: Fix presentational use of .SS.
