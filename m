From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnftnl 1.0.3 release
Date: Tue, 16 Dec 2014 00:21:13 +0100
Message-ID: <20141215232112.GA11371@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnftnl 1.0.3

libnftnl is a userspace library providing a low-level netlink
programming interface (API) to the in-kernel nf_tables subsystem. The
library libnftnl has been previously known as libnftables. This
library is currently used by the nft command line tool.

This release comes with new features available up to 3.18, see
ChangeLog for more details.

You can download this library from:

http://www.netfilter.org/projects/libnftnl/downloads.html
ftp://ftp.netfilter.org/pub/libnftnl/

Have fun!

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-libnftnl-1.0.3.txt"
Content-Transfer-Encoding: 8bit

Alvaro Neira (2):
      ruleset: add set id to parsed sets
      src: internal set id allocation from nft_ruleset_parse*()

Ana Rey (15):
      chain: Free memory in the same function that is reserved
      chain: Use nft_rule_expr_set_* in the xml parsing code
      table: Free memory in the same function that is reserved
      table: Use nft_table_attr_set_* in the xml functions
      table: Add set, unset and parse implementation for the use attribute
      table: Do not print unset values in xml file
      table: Do not print unset values in json file
      chain: Add all support of use attribute
      chain: Do not print unset attributes in xml
      chain: Rename variables in nft_jansson_parse_chain functions
      chain: Do not print unset attributes in json
      expr: meta: Add pkttype support
      expr: meta: Add cpu support for meta expresion
      expr: meta: Add devgroup support
      expr: meta: Add cgroup support

Arturo Borrero (33):
      set: add support for set mechanism selection
      examples: nft-set-add: use batch infraestructure
      examples: nft-chain-del: add chain_del_parse()
      examples: nft-chain-del: support new batching interface
      set_elem: use proper free function
      examples: merge nft-chain-{xml|json}-add.c
      examples: nft-chain-parse-add: add batching support
      examples: merge nft-table-{xml|json}-add.c
      examples: nft-table-parse-add: add batching support
      examples: nft-table-add: add table_add_parse()
      examples: nft-table-add: add batching support
      examples: nft-table-del: add table_del_parse()
      examples: nft-table-del: add batching support
      src: fix printing of XML/JSON event wrapper header/footer
      expr: nat: add support for the new flags attribute
      expr: add new nft_masq expression
      nf_tables.h: add NFTA_MASQ_UNSPEC
      utils: nft_fprintf: prevent an empty buffer from being printed
      set: fix set nlmsg desc parsing
      examples: merge nft-rule-{xml|json}-add.c
      examples: nft-rule-parse-add: add batching support
      examples: nft-set-json-add: generalize parsing format support
      examples: nft-set-parse-add: add batching support
      examples: nft-table-add: fix wrong buffer pointer
      expr: masq: optional printing of flags attr in snprintf_default
      tests: add tests for the masq expression
      tests: also test nat flags attribute
      src: cleanup in mxml and jansson regarding set_id parsing
      utils: fix arp family number
      ruleset: deconstify _get interface
      src: add support for nft_redir expression
      tests: add tests for nft_redir expression
      examples: nft-rule-parse-add: fix wrong buffer usage when building rule header

Giuseppe Longo (1):
      buffer: include stdarg header

Pablo Neira Ayuso (16):
      expr: log: add support for level and flags
      src: stricter netlink attribute length validation
      set_elem: add nft_set_elems_nlmsg_build_payload_iter()
      common: add batching interfaces
      examples: nft-chain-add: add chain_add_parse()
      examples: nft-chain-add: support new batching interface
      utils: define xfree() as macro
      src: get rid of cached copies of x_tables.h and xt_LOG.h
      src: add ruleset generation class
      src: fix compilation without xml/json support
      remove empty src/attr.c
      expr: nat: use 'nat_type' instead of 'type' in the parser
      src: consolidate XML/JSON exportation
      expr: data_reg: use 'reg' instead of 'data_reg'
      bump version to 1.0.3
      include: add missing gen.h to Makefile.am

Álvaro Neira Ayuso (1):
      expr: log: define variable flags in xml parser


--PNTmBPCT7hxwcZjr--
