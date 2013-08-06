From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.20 release
Date: Tue, 6 Aug 2013 18:17:08 +0200
Message-ID: <20130806161708.GA27532@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.20

iptables is the userspace command line program used to configure the
Linux kernel packet filtering software. It is targeted towards system
administrators.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.20.txt"

Alexey Perevalov (1):
      doc: clarify DEBUG usage macro

Andy Spencer (1):
      iptables: use autoconf to process .in man pages

Eric Leblond (1):
      configure: display summary

Florian Westphal (2):
      extensions: libipt_ULOG: man page should mention NFLOG as replacement
      extensions: libxt_connlabel: use libnetfilter_conntrack

Jozsef Kadlecsik (2):
      Introduce a new revision for the set match with the counters support
      libxt_CT: Add the "NOTRACK" alias

Mart Frauenlob (7):
      libip6t_mh: Correct command to list named mh types in manpage
      extensions: libxt_DNAT: rename IPv4 manpage and tell about IPv6 support
      extensions: libxt_REDIRECT: rename IPv4 manpage and tell about IPv6 support
      extensions: libxt_NETMAP: rename IPv4 manpage and tell about IPv6 support
      extensions: libxt_SNAT: rename IPv4 manpage and tell about IPv6 support
      extensions: libxt_MASQUERADE: rename IPv4 manpage and tell about IPv6 support
      extensions: libxt_LOG: rename IPv4 manpage and tell about IPv6 support

Pablo Neira Ayuso (7):
      extensions: libxt_LED: fix parsing of delay
      Merge branch 'stable'
      Merge branch 'stable'
      ip{6}tables-restore: fix breakage due to new locking approach
      libxt_recent: restore minimum value for --seconds
      iptables-xml: fix parameter parsing (similar to 2165f38)
      iptables 1.4.20 release

Patrick McHardy (1):
      extensions: add copyright statements

Phil Oester (7):
      xtables: improve get_modprobe handling
      ip[6]tables: Add locking to prevent concurrent instances
      iptables: Fix connlabel.conf install location
      ip6tables: don't print out /128
      libip6t_LOG: target output is different to libipt_LOG
      build: additional include path required after UAPI changes
      iptables: iptables-xml: Fix various parsing bugs

Russell Senior (1):
      libxt_recent: restore reap functionality to recent module

Willem de Bruijn (1):
      build: fail in configure on missing dependency with --enable-bpf-compiler

holger@eitzenberger.org (1):
      extensions: libxt_NFQUEUE: add --queue-cpu-fanout parameter


--AhhlLboLdkugWU4S--
