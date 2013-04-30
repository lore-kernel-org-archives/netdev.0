From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 3.9.0
Date: Tue, 30 Apr 2013 07:56:45 -0700
Message-ID: <20130430075645.1747b8ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is update for iproute2 tools for 3.9 kernel.
In addition the usual documentation fixes, this version includes the
utilities to manage forwarding tables in bridge and vxlan.

If you have been sitting on changes to iproute2 that are in
net-next for 3.10 merge window, please submit them now.

Iproute2 package is available at:
  http://kernel.org/pub/linux/utils/net/iproute2/iproute2-3.9.0.tar.gz

You can download the source from:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Alexander Duyck (1):
      libnetlink: Use ifinfomsg instead of rtgenmsg in rtnl_wilddump_re=
q_filter

David Stevens (1):
      generalize VXLAN forwarding tables

David Ward (9):
      ip/iptunnel: Fix incorrect syntax in man page
      iplink_vlan: Add flag for Multiple VLAN Registration Protocol (MV=
RP)
      ip/xfrm: Extend SPI validity checking
      ip/xfrm: Do not allow redundant algorithm combinations to be spec=
ified
      ip/xfrm: Improve transform protocol-specific parameter checking
      ip/xfrm: Do not print a zero-length algorithm key
      ip/xfrm: Command syntax should not expect a key for compression
      ip/xfrm: Improve usage text and documentation
      ip/xfrm: Improve error strings

Eric W. Biederman (1):
      iproute2: Document the -D and -I options

Hannes Frederic Sowa (2):
      ss: show send queue length on unix domain sockets
      ss: show socket memory stats for unix sockets if requested

Hubert Kario (1):
      add short description of batch mode in tc man page

James Chapman (2):
      iproute2: add l2spec_type param to l2tp add session
      iproute2: update ip-l2tp man page

Nicolas Dichtel (1):
      libnetlink: check flag NLM_F_DUMP_INTR during dumps

Petr Sabata (1):
      iproute2: Fix some manpage typos

Petr =C5=A0abata (1):
      iproute2: Mention the 'up' argument in documentation

Stephen Hemminger (22):
      ss: use rta_getattr_u32
      ip: fix ipv6 ntable on ppc64
      Update kernel headers to 3.9.0-rc1
      fix dependency on sizeof(__u64) =3D=3D sizeof(unsigned long long)
      ipntable: more fixes for ppc64
      Revert "generalize VXLAN forwarding tables"
      bridge: cleanup usage message
      Fix build when shared libraries are disabled
      ipmaddr: add whitespace around =3D
      ipaddress: minor white space cleanup
      bridge: add oneline option
      tc-tbf: remove ancient references to Alpha
      ll_map: remove unused address fields
      ll_map: use net/if.h to get prototype
      ll_map: add name and index hash
      ip: remove unnecessary ll_init_map
      Update kernel headers to 3.9-rc5
      utils: fix range checking for get_u32/get_u64 et all
      add linux/fs.h
      Revert "add linux/fs.h"
      ipnetns: fix build on older systems
      v3.9.0

Thomas Egerer (2):
      ip xfrm state: Allow different selector family
      ip xfrm state: Allow different selector family

Vijay Subramanian (1):
      Fix compilation error of m_ipt.c with -Werror enabled

Vlad Yasevich (6):
      bridge: Add vlan support to fdb entries
      bridge: Add vlan configuration support
      bridge: Update bridge man pages to include vlan command
      bridge: Add support for setting bridge port attributes
      bridge: Add support for printing bridge port attributes
      man: Add documentation for the bridge link operation.

roopa (1):
      Fix -oneline output when alias present
