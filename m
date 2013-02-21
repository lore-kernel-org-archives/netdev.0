From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 3.8.0
Date: Thu, 21 Feb 2013 09:00:20 -0800
Message-ID: <20130221090020.52330a78@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to iproute2 utilities to support features in 3.8.0 release
and lots of small spelling and documentation fixes.

iproute2 package is available at:
  http://kernel.org/pub/linux/utils/net/iproute2/iproute2-3.8.0.tar.gz

You can download the source from:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Please submit your changes now for features that are going into 3.9 kernel.

Andreas Henriksson (1):
      iproute2: fix tc ematch manpage section

Benjamin Poirier (1):
      Use pkg-config to obtain xtables.h path

Cong Wang (7):
      iproute2: add mdb sub-command to bridge
      iproute2: implement add/del mdb entry
      iproute2: add support to monitor mdb entries too
      iproute2: update usage info of bridge monitor
      bridge: distinguish permanent and temporary mdb entries
      bridge: make `bridge mdb` output consistent with input
      bridge: update help

David L Stevens (1):
      add DOVE extensions for iproute2

David Ward (1):
      ip/iptunnel: Extend TOS syntax

Eric W. Biederman (6):
      iproute2: Don't propogate mounts out of ip
      iproute2: Normalize return codes in "ip netns"
      iproute2: Improve "ip netns add" failure error message
      iproute2: Make "ip netns delete" more likely to succeed
      iproute2: Fill in the ip-netns.8 manpage
      iproute2: Add "ip netns pids" and "ip netns identify"

Jamal Hadi Salim (1):
      iproute2: act_ipt fix xtables breakage

Jan Engelhardt (1):
      build: unbreak linakge of m_xt.so

Johannes Naab (1):
      iproute2: tc netem rate: allow negative packet/cell overhead

Kees van Reeuwijk (6):
      iproute2: clarification of various man8 pages
      iproute2: clarifications in the tc-hfsc.7 man page
      iproute2: add a missing return statement
      iproute2: clarifications in the libnetlink.3 man page
      iproute2: improved error messages
      iproute2: clearer error messages for fifo and tbf qdiscs

Lutz Jaenicke (1):
      rtnl_wilddump_request: fix alignment issue for embedded platforms

Mike Frysinger (6):
      configure: move toolchain init to a function
      lib: include the Config file too
      configure: pull AR from the env too
      add man7 to subdirs list
      do not ignore errors in man subdirs
      ipxfrm: use alloca to allocate stack space

Nicolas Dichtel (15):
      ip/ip6tunnel: fix help for TCLASS
      ip/ip6tunnel: reset encap limit flag on change
      ip/ip6tunnel: fix update of tclass and flowlabel
      ip: add support of netconf messages
      ip: add support of 'ip link type ip6tnl'
      ip: add support of 'ip link type [ipip|sit]'
      ip/link_iptnl: fix indentation Logged in as shemminger
      ip: update mand pages and usage() for 'ip mroute'
      ip: update man pages for 'ip link'
      ip: term OPTIONS was used twice in 'ip route' man pages
      ip: use rtnelink to manage mroute
      ip: add man pages for netconf
      ip: update man pages and usage() for 'ip monitor'
      ipaddr: fix a typo in error msg about SIOCGIFTXQLEN
      iplink: display the value of IFLA_PROMISCUITY

Stephen Hemminger (14):
      Update kernel headers to 3.8-pre
      bridge: add if_bridge.h header
      build: indent shell functions in configure
      configure: restore old behaviour
      bridge: update kernel headers
      README: update mail address and download location
      Makefile: make warnings into errors
      libnetlink: add caveat
      ip: change format of promiscuity display
      ip: make local functions static
      lib: make string arguments const
      Makefile: turn on warnings about missing prototypes
      ip: handle flush with table > 2^31
      v3.8.0

Strake (1):
      include needed files

Zhi Yong Wu (1):
      ip: add the type 'vxlan' in the output of "ip link help"
