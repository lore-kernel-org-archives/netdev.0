From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.12
Date: Fri, 22 Jul 2011 15:02:18 +0200
Message-ID: <4E2974DA.3050306@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080100030801070401010300"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080100030801070401010300
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.12

the iptables release for the 3.0.0 kernel. Changes include:

- regression fixes for problems reported for the 1.4.11.1 release

- more conversions to the guided option parser

- fixes for problems detected by the coverity scanner

- documentation updates

See the attached changelogs for the full list of changes.

Version 1.4.12 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team,
Happy firewalling!

--------------080100030801070401010300
Content-Type: text/plain;
 name="changes-iptables-1.4.12.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="changes-iptables-1.4.12.txt"

Fernando Luis Vazquez Cao (1):
      doc: document IPv6 TOS mangling bug in old Linux kernels

Jakub Zawadzki (1):
      doc: fix group range in libxt_NFLOG's man

Jan Engelhardt (23):
      doc: include matches/targets in manpage again
      libipt_LOG: fix ignoring all but last flags
      libxt_RATEEST: use guided option parser
      iptables: consolidate target/match init call
      extensions: support for per-extension instance "global" variable space
      libxt_rateest: abolish global variables
      libxt_RATEEST: abolish global variables
      libip6t_HL: fix option names from ttl -> hl
      libxt_state: fix regression about inversion of main option
      libxt_hashlimit: use a more obvious expiry value by default
      build: bump soversion for recent data structure change
      build: attempt to fix building under Linux 2.4
      doc: mention multiple verbosity flags
      build: install modules in arch-dependent location
      doc: fix version string in ip6tables.8
      doc: the -m option cannot be inverted
      iptables: restore negation for -f
      libxtables: properly reject empty hostnames
      libxtables: ignore whitespace in the multiaddress argument parser
      option: remove last traces of intrapositional negation
      libxtables: set clone's initial data to NULL
      libxt_conntrack: restore network-byte order for v1,v2
      libxt_conntrack: move more data into the xt_option_entry

Jiri Popelka (5):
      iptables: Coverity: DEADCODE
      iptables: Coverity: NEGATIVE_RETURNS
      iptables: Coverity: REVERSE_INULL
      iptables: Coverity: VARARGS
      iptables: Coverity: RESOURCE_LEAK

Martin F. Krafft (1):
      iptables-apply: select default rule file depending on call name

Massimo Maggi (1):
      libxt_RATEEST: fix userspacesize field

Patrick McHardy (4):
      Merge branch 'master' of git://dev.medozas.de/iptables
      Merge branch 'master' of git://dev.medozas.de/iptables
      Merge branch 'master' of git://dev.medozas.de/iptables
      Bump version to 1.4.12


--------------080100030801070401010300--
