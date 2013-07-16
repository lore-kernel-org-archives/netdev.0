From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 3.10
Date: Tue, 16 Jul 2013 10:17:48 -0700
Message-ID: <20130716101748.166a8ad7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is update for iproute2 tools for 3.10 kernel.
In addition to the usual array of bug fixes and documentation changes,
this release also fixes some important bugs relating to rate control
at higher speeds.

The 3.10 kernel added a number of new networking features as well
for VXLAN and bridging.

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

John Fastabend (1):
      iproute2: bridge: fix 'bridge link' setlink/getlink parsing

JunweiZhang (1):
      ipbatch: fix use of 'ip netns exec'

Kamil Rytarowski (1):
      iproute2 patch against GCC 4.8.0

Nicolas Dichtel (5):
      ip: add missing help about mode argument
      ip/xfrm: all to set flag XFRM_SA_XFLAG_DONT_ENCAP_DSCP
      ipnetconf: by default dump all entries
      ss: allow to retrieve AF_PACKET info via netlink
      man: describe --bpf option of ss

Patric McHardy (1):
      ip: iplink_vlan: add 802.1ad support

Pavel Emelyanov (1):
      ss: Show inet and unix sockets' shutdown state

Rami Rosen (1):
      ss: replace bfp with bpf in usage().

Sriram Narasimhan (1):
      iptuntap: allow creation of multi-queue tun/tap device

Stephen Hemminger (11):
      Update headers to 3.10
      Add vxlan destination port option
      vxlan: nag user to set port value
      add BPF header files
      vxlan: remove dstport option
      man: get rid of useless reference to GNU style options
      htb: fix indentation
      netns: follow return value conventions of the rest of the code
      ip: add batch mode to man page
      Make tc and ip batch mode consistent
      v3.10.0

Thomas Richter (2):
      iproute2 vxlan documentation update for bridge command
      iproute2 vxlan documentation update for ip command

Eric S. Raymond (4):
      First set of manpage markup fixes
      tc-stab.8: Fix synopsis errors, an invalid escape, and incorrect English usge.
      In tc-ematch.8, remove no-op .ti requests to prevent translation warnings
      ip-rule.8: Fix presentational use of .SS.
