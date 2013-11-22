From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.21 release
Date: Fri, 22 Nov 2013 13:12:32 +0100
Message-ID: <20131122121232.GA5698@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.21

iptables is the userspace command line program used to configure the
Linux packet filtering ruleset. It is targeted towards system administrators.
Since Network Address Translation is also configured from the packet filter
ruleset, iptables is used for this, too. The iptables package also includes
ip6tables. ip6tables is used for configuring the IPv6 packet filter.

This release includes fixes and a couple of new features:

* --nowildcard option for xt_socket, available since Linux kernel 3.11,
  from Eric Dumazet.

* SYNPROXY support, available since Linux kernel 3.12, from Patrick McHardy.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.21.txt"

Eric Dumazet (1):
      xt_socket: add --nowildcard flag

Florian Westphal (3):
      extensions: libxt_socket: update man page
      doc: add libnetfilter_queue pointer to libxt_NFQUEUE.man
      doc: merge ip6table man pages into ipv4 ones

Jozsef Kadlecsik (1):
      extensions: libxt_set, libxt_SET: check the set family too

Kevin Cernekee (1):
      ip6tables: Use consistent exit code for EAGAIN

Laurence J. Lane (8):
      iptables: libxt_hashlimit.man: correct address
      iptables: libxt_conntrack.man extraneous commas
      iptables: libip(6)t_REJECT.man default icmp types
      iptables: iptables-xm1.1 correct man section
      iptables: libxt_recent.{c,man} dead URL
      iptables: libxt_string.man add examples
      extensions: libxt_LOG: use generic syslog reference in manpage
      iptables: extensions/GNUMakefile.in use CPPFLAGS

Lutz Jaenicke (1):
      iptables: correctly reference generated file

Pablo Neira Ayuso (7):
      Merge branch 'stable-1.4.20'
      Merge branch 'stable-1.4.20'
      ip[6]tables: fix incorrect alignment in commands_v_options
      build: add software version to manpage first line at configure stage
      extensions: libxt_cluster: add note on arptables-jf
      utils: nfsynproxy: fix error while compiling the BPF filter
      iptables 1.4.21 release

Patrick McHardy (2):
      extensions: add SYNPROXY extension
      utils: add nfsynproxy tool

Phil Oester (4):
      iptables: state match incompatibilty across versions
      libxtables: xtables_ipmask_to_numeric incorrect with non-CIDR masks
      iptables: improve chain name validation
      iptables: spurious error in load_extension

stephen hemminger (1):
      xtables: trivial spelling fix


--Qxx1br4bt0+wmkIi--
