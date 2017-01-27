From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.6.1 release
Date: Fri, 27 Jan 2017 22:00:36 +0100
Message-ID: <20170127210036.GA15758@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
        netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

	iptables 1.6.1

iptables is the userspace command line program used to configure the
Linux 2.4.x and later packet filtering ruleset. It is targeted towards
system administrators.

This update contains accumulated bugfixes, several new extensions and
lots of translations via iptables-translate to ease migration to
nftables.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-iptables-1.6.1.txt"
Content-Transfer-Encoding: 8bit

Ana Rey (1):
      extensions: libxt_udp: add translation to nft

Arpan Kapoor (1):
      libxtables: Replace gethostbyname() with getaddrinfo()

Arturo Borrero (3):
      extensions/libxt_rpfilter.man: fix typo, specifiy vs specify
      iptables/xtables-arp.c: fix typo, wierd vs weird
      extensions/libxt_tcp: fix nftables translate flags value, 'none' vs '0x0'

Arturo Borrero Gonzalez (1):
      extensions: update Arturo Borrero email address

Brian Haley (1):
      iptables-restore: add missing arguments to usage message

Florian Westphal (5):
      iptables.8: mention iptables-save in -L documentation
      iptables.8: nat table has four builtin chains
      extensions: NETMAP: add ' to:' prefix when printing NETMAP target
      extensions: NETMAP: fix iptables-save output
      connlabel: clarify default config path

George Burgess IV (1):
      libxt_multiport: remove an unused variable

Giuseppe Longo (1):
      configure: make libmnl and libnftnl hard requirements

Guruswamy Basavaiah (4):
      iptables: extensions: iptables-translate prints extra "nft" after printing any error
      iptables-translate: translate iptables --flush
      iptables-translate: Printing the table name before chain name.
      iptables-translate: Don't print "nft" in iptables-restore-translate command

Gustavo Zacarias (1):
      iptables: add xtables-config-parser.h to BUILT_SOURCES

Janani Ravichandran (1):
      extensions: libip6t_rt.c: Add translation to nft

Jordan Yelloz (1):
      extensions: added AR substitution

Keno Fischer (1):
      build: Fix two compile errors during out-of-tree build

Laura Garcia Liebana (12):
      extensions: libip6t_icmp6: Add translation to nft
      extensions: libipt_LOG: Avoid to print the default log level in the translation
      extensions: libipt_icmp: Add translation to nft
      extensions: libipt_REJECT: Avoid to print the default reject with value in the translation
      extensions: libip6t_REJECT: Avoid to print the default reject with value in the translation
      extensions: libxt_ipcomp: Add translation to nft
      extensions: libip6t_hbh: Add translation to nft
      extensions: libxt_multiport: Add translation to nft
      extensions: libxt_dscp: Add translation to nft
      extensions: libip6t_frag: Add translation to nft
      extensions: libxt_cgroup: Add translation to nft
      extensions: libxt_conntrack: Add translation to nft

Liping Zhang (27):
      extensions: libxt_limit: fix a wrong translation to nft rule
      extensions: libxt_mark: fix a wrong translation to nft when mask is specified
      extensions: libxt_TRACE: Add translation to nft
      extensions: libipt_realm: fix order of mask and id when do nft translation
      extensions: libxt_connlabel: fix crash when connlabel.conf is empty
      extensions: libxt_connlabel: Add translation to nft
      extensions: libxt_NFLOG: display nflog-size even if it is zero
      extensions: libxt_NFLOG: translate to nft log snaplen if nflog-size is specified
      extensions: libxt_NFLOG: add unit test to cover nflog-size with zero
      extensions: libxt_connlabel: add unit test
      iptables-translate: add in/out ifname wildcard match translation to nft
      extensions: libxt_CLASSIFY: Add translation to nft
      extensions: libipt_DNAT/SNAT: fix "OOM" when do translation to nft
      extensions: libip[6]t_SNAT/DNAT: use the new nft syntax when do xlate
      extensions: libip[6]t_REDIRECT: use new nft syntax when do xlate
      extensions: libip6t_SNAT/DNAT: add square bracket in xlat output when port is specified
      extensions: libipt_realm: add a missing space in translation
      extensions: libxt_iprange: rename "ip saddr" to "ip6 saddr" in ip6tables-xlate
      extensions: libxt_iprange: handle the invert flag properly in translation
      extensions: libxt_devgroup: handle the invert flag properly in translation
      extensions: libxt_ipcomp: add range support in translation
      extensions: libxt_quota: add translation to nft
      extensions: libxt_DSCP: add translation to nft
      extensions: libxt_statistic: add translation to nft
      extensions: LOG: add log flags translation to nft
      extensions: libxt_connbytes: Add translation to nft
      extensions: libxt_rpfilter: add translation to nft

Loganaden Velvindron (1):
      libxt_TCPOPTSTRIP: Fix musl compatibility

Pablo M. Bermudo Garay (11):
      extensions: iprange: remove extra space in translation
      iptables-compat: use nft built-in comments support
      xtables-translate: fix multiple spaces issue
      include: xtables: fix struct definitions grepability
      xtables-translate: fix issue with quotes
      xtables-compat: fix comments listing
      xtables-compat: remove useless functions
      xtables-translate: add escape_quotes option to comment_xlate
      xtables-compat: check if nft ruleset is compatible
      xtables-compat: add rule cache
      xtables-translate-restore: do not escape quotes

Pablo Neira Ayuso (13):
      nft: xtables: add generic parsing infrastructure to interpret commands
      nft: xtables-restore: add generic parsing infrastructure
      nft: xtables: add the infrastructure to translate from iptables to nft
      extensions: libxt_tcp: add translation to nft
      extensions: libxt_state: add translation to nft
      libxtables: fix leak in xt_buf object
      extensions: rename xt_buf to xt_xlate
      xtables: add xt_xlate_add_comment()
      iptables-translate: pass ipt_entry and ip6t_entry to ->xlate()
      libxtables: missing comment initialization in xt_xlate_alloc()
      src: introduce struct xt_xlate_{mt,tg}_params
      configure: update libnetfilter_conntrack version dependency
      iptables 1.6.1 release

Phil Sutter (5):
      extensions: libip6t_ah: Fix translation of plain '-m ah'
      xtables-translate: Support setting standard chain policy
      nft_ipv{4,6}_xlate: Respect prefix lengths
      xtables-translate: Fix chain type when translating nat table
      tcp_xlate: Enclose LH flag values in parentheses

Rami Rosen (1):
      extensions: fix cgroup2 help message in libxt_cgroup.c.

Roberto García (7):
      extensions: libip6t_LOG: Avoid to print the default log level in the translation
      iptables: extensions: libxt_TEE: Add translation to nft
      extensions: libxt_MARK: Add translation to nft
      extensions: libxt_MARK: Add translation for revision 1 to nft
      extensions: libxt_CONNMARK: Add translation to nft
      iptables: extensions: libxt_MARK: Fix translation of --set-xmark option
      iptables: extensions: libxt_ecn: Add translation to nft

Sami Kerola (1):
      extensions: REJECT: do not adjust reject-with type footnote indentation

Shivani Bhardwaj (51):
      extensions: libxt_mark: Add translation to nft
      extensions: libxt_esp: Add translation to nft
      extensions: libxt_NFLOG: Add translation to nft
      extensions: libxt_iprange: Add translation to nft
      extensions: libxt_mac: Add translation to nft
      extensions: libxt_helper: Add translation to nft
      extensions: libxt_NFLOG: Add group_info and remove multiple keywords
      extensions: libxt_limit: Add translation to nft
      include: xtables: Add enum for better nft translation code
      extensions: libxt_mark: Fix inversion code
      extensions: libxt_devgroup: Add translation to nft
      extensions: libxt_cpu: Add translation to nft
      extensions: libipt_ah: Add translation to nft
      extensions: libxt_connmark: Add translation to nft
      extensions: libxt_pkttype: Add translation to nft
      extensions: libipt_REJECT: Add translation to nft
      extensions: libipt_realm: Add translation to nft
      extensions: libipt_SNAT: Add translation to nft
      extensions: libipt_DNAT: Add translation to nft
      iptables: nft-ipv6: Replace ip with ip6
      extensions: libip6t_DNAT: Add translation to nft
      extensions: libip6t_SNAT: Add translation to nft
      extensions: libxt_length: Add translation to nft
      extensions: libip6t_ah: Add translation to nft
      extensions: libipt_ttl: Add translation to nft
      extensions: libip6t_REJECT: Add translation to nft
      extensions: libipt_LOG: Add translation to nft
      extensions: libip6t_LOG: Add translation to nft
      extensions: libip6t_hl: Add translation to nft
      extensions: libipt_REDIRECT: Add translation to nft
      extensions: libip6t_REDIRECT: Add translation to nft
      iptables: nft-ipv6: Fix ipv6 flags
      extensions: libxt_NFQUEUE: Add translation to nft
      comment: Add translation to nft
      extensions: libipt_MASQUERADE: Add translation to nft
      extensions: libip6t_MASQUERADE: Add translation to nft
      iptables: nft-ipv6: Use meta l4proto instead of nexthdr
      extensions: libip6t_mh: Add translation to nft
      extensions: libxt_owner: Add translation to nft
      extensions: libxt_sctp: Add translation to nft
      extensions: libxt_dccp: Add translation to nft
      configure: Show support for connlabel
      extensions: libxt_NFQUEUE: Fix bug with order of fanout and bypass
      extensions: libxt_NFQUEUE: Unstack different versions
      extensions: libxt_NFQUEUE: Add missing tests
      extensions: libxt_connmark: Fix order of mask and mark
      extensions: libxt_devgroup: Fix order of mask and id
      configure: Remove flex check warning
      configure: Fix assignment statement
      iptables: xtables-arp: Use getaddrinfo()
      extensions: libxt_mangle: Use getaddrinfo()

Shyam Saini (3):
      libxtables: xtables: remove unnecessary debug code
      libxtables: xtables: Use getnameinfo()
      iptables: fix the wrong appending of jump verdict after the comment.

Subash Abhinov Kasiviswanathan (1):
      xtables: Add an interval option for xtables lock wait

Tejun Heo (3):
      libxt_cgroup: prepare for multi revisions
      libxt_cgroup2: add support for cgroup2 path matching
      extensions: libxt_cgroup: add unit test

Thomas Habets (1):
      iptables-save: exit with error if unable to open proc file

Thomas Woerner (1):
      ip6tables: Warn about use of DROP in nat table

Vishwanath Pai (3):
      extensions: libxt_NFLOG: nflog-range does not truncate packets
      extensions: libxt_hashlimit: Prepare libxt_hashlimit.c for revision 2
      extensions: libxt_hashlimit: Create revision 2 of xt_hashlimit to support higher pps rates

Willem de Bruijn (3):
      extensions/libxt_bpf.man: clarify BPF code generation with tcpdump
      extensions: libxt_bpf: support ebpf pinned objects
      iptables: on revision mismatch, do not call print/save

Xose Vazquez Perez (1):
      iptables: update pf.os


--dDRMvlgZJXvWKvBx--
