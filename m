From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.3
Date: Mon, 23 Mar 2009 15:28:32 +0100
Message-ID: <49C79C90.80804@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090501090206030603020205"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter <netfilter@lists.netfilter.org>,
	netfilter-announce@lists.netfilter.org
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090501090206030603020205
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

     iptables version 1.4.3

the iptables release for the 2.6.29 kernel. It has been some time
since the last release and we've had a lot of changes all over the
place. Besides the usual fixes and cleanups, we have:

- numerous documentation updates from Jan Engelhardt and others

- a set of changes to move some of the iptables functionality to
   a shared library for tc and m_ipt from Jan and Jamal Hadi Salim

- another patch to make libiptc available as shared library. Some
   distributions have been carrying patches for this despite being
   explicitly unsupported. The library does not guarantee a stable
   API, but it should make life for distributors a bit easier.

- IPv6 support for the recent match from Jan

- TPROXY support by Krisztian Kovacs

- SCTP/DCCP NAT support by myself

And lots of smallish changes, almost 90% of which are from Jan.
Check out the Changelog for more details.

This release starts enforcing the deprecation of NAT filtering that
was added in 1.4.2-rc1, filtering rules in the NAT tables will cause
an error instead of a warning from now on. Please make sure your
rulesets are update appropriately.

Version 1.4.3 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------090501090206030603020205
Content-Type: text/plain;
 name="changes-iptables-1.4.3.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.3.txt"

Bart De Schuymer (1):
      man: fix physdev manpage

Christian Perle (1):
      libxt_policy: cannot set spi/reqid numbers higher than 0x7fffffff

Christoph Paasch (1):
      libiptc: avoid compile warnings for iptc_insert_chain

Daniel Drake (1):
      libxt_owner: add more spaces to output

Eric Leblond (1):
      xt_NFLOG: Set default NFLOG qthreshold to 0

Jamal Hadi Salim (12):
      libxtables: Introduce global params structuring
      libxtables: define xtables_free_opts()
      libxtables: Add exit_error cb to xtables_globals
      libxtables: Make ip6tables, iptables and iptables-xml use xtables_globals
      libxtables: Replace direct exit_error() calls inside libxtables
      libxtables: simple aliasing macro for exit_error
      libxtables: set names of programs
      libxtables: add xtables_set_revision
      libxtables: make iptables and ip6tables use xtables_free_opts
      libxtables: consolidate merge_options into xtables_merge_options
      libxtables: consolidate init calls into one function
      libxtables: general follow-up cleanup

Jan Engelhardt (84):
      Move libipt_recent to libxt_recent
      libxt_recent: add IPv6 support
      manpage: use separate paragraphs for command syntax
      manpage: explain what rule-specification is
      libiptc: remove typedef indirection
      libiptc: remove indirections
      libiptc: remove unused iptc_get_raw_socket and iptc_check_packet
      libiptc: use hex output for hookmask
      libxt_conntrack: respect -n option during ruledump
      libiptc: make sockfd a per-handle thing
      libxt_conntrack: dump ctdir
      src: reuse the global modprobe_program variable
      src: use NFPROTO_ constants
      src: remove inclusion of iptables.h
      doc: fix a typo in libip6t_REJECT.man
      libiptc: guard chain index allocation for different malloc implementations
      src: remove unused include files
      iptables-save: output ! in position according to manpage
      rateest: guard against segfault
      env: augment deprecation notice
      build: resolve autotools suggestions
      doc: put iptables version into manpage
      doc: resynchronize markup in iptables,ip6tables.8.in
      doc: escape minus sign in manpages
      build: use regular = assignments in Makefile
      build: remove non-portable rule
      doc: escape minus sign in manpage (2)
      doc: augment ICMP manpage by type/code syntax
      src: remove redundant returns at end of void-returning functions
      src: remove redundant casts
      libxt_owner: use correct UID/GID boundaries
      extensions: use UINT_MAX constants over open-coded bits (1/2)
      extensions: use UINT_MAX constants over open-coded numbers (2/2)
      libxtables: prefix/order - fw_xalloc
      libxtables: prefix/order - modprobe and xtables.ko loading
      libxtables: prefix/order - match/target loading
      libxtables: prefix/order - libdir
      libxtables: prefix/order - strtoui
      libxtables: prefix/order - program_name
      libxtables: prefix/order - param_act
      libxtables: prefix/order - ipaddr/ipmask to ascii output
      libxtables: prefix/order - ascii to ipaddr/ipmask input
      libxtables: prefix - misc functions
      libxtables: prefix - parse and escaped output func
      libxtables: prefix/order - move check_inverse to xtables.c
      libxtables: prefix/order - move parse_protocol to xtables.c
      libbxtables: prefix names and order it #1
      libxtables: prefix names and order it #2
      libxtables: prefix names and order #3
      libxtables: move afinfo around
      Merge branch 'origin/master'
      libxtables: recognize IP6TABLES_LIB_DIR old-style environment variable
      build: move -ldl to proper LDADD
      libxtables: remove unused XT_LIB_DIR macro
      libxtables: decouple non-xtables parts from header
      src: remove iptables_rule_match indirection macro
      src: remove unused ipt_tryload macro
      libxtables: move compat defines to xtables.c
      src: consolidate duplicate code in iptables/internal.h
      libxtables: use const for vars holding literals
      libxt_string: fix undefined behavior/incorrect patlen calculation
      libxtables: flush before fork
      libipq: add missing doc for NF_ values
      build: restructure Makefile for include/ directory
      libipq: fix compile error
      build: remove unneeded -ldl from iptables_xml_LDADD
      libiptc: make library available as a shared library
      build: trigger reconfigure when extensions/GNUmakefile.in changes
      doc: do not put IPv4 doc into ip6tables.8
      doc: resynchronize manpage with in-code help
      libxtables: inline and remove unused OPTION_OFFSET macro
      libxtables: prefix exit_error to xtables_error
      extensions: remove unwanted/add needed includes for IPv6 exts
      extensions: remove unwanted/add needed includes for IPv4 exts
      libxt_policy: use bounded strtoui
      include: resynchronize headers with 2.6.29-rc5
      extensions: add missing limits.h include
      iptables: turn deprecation warning into enforcing mode
      Merge commit 'nf/master'
      libxt_connbytes: minor manpage adustments
      libxt_connbytes: document nf_ct_acct behavior
      libxtables: add -I/-L flags to pkgconfig files
      libxt_comment: output quotes must be escaped in
      iptables-save: module loading corrections

Jesper Dangaard Brouer (3):
      libiptc: fix chain rename bug in libiptc
      libiptc: fix whitespaces and typos
      libiptc: give credits to my self

Jirí Moravec (1):
      libxt_TOS: fix compilation error

KOVACS Krisztian (2):
      Add iptables support for the TPROXY target
      Add iptables support for the socket match

Marc Fournier (1):
      doc: fix option typo in libxt_multiport

Pablo Neira Ayuso (5):
      iptables: fix error reporting with wrong/missing arguments
      state: report spaces in the state list parsing
      iptables: refer to dmesg when we hit error
      string: fix wrong pattern length calculation
      iptables: fix broken options-merging during libxtables rework

Patrick McHardy (5):
      Add SCTP/DCCP support to NAT targets
      Bump version to 1.4.3-rc1
      Merge branch 'master' of git://dev.medozas.de/iptables
      Merge branch 'master' of git://dev.medozas.de/iptables
      Bump version to 1.4.3

Shaul Karl (1):
      doc: fix one layout issue in iptables-restore.8

Stephen Hemminger (1):
      iptables: Add limits.h to get INT_MIN, INT_MAX, ...

Thomas Jarosch (2):
      Fix compile error in libxt_iprange.c using gcc 4.3.2
      Fix compile warnings using gcc 4.3.2


--------------090501090206030603020205--
