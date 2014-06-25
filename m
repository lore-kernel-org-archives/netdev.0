From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnftnl 1.0.2 release
Date: Wed, 25 Jun 2014 17:57:15 +0200
Message-ID: <20140625155715.GA16261@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnftnl 1.0.2

libnftnl is a userspace library providing a low-level netlink
programming interface (API) to the in-kernel nf_tables subsystem. The
library libnftnl has been previously known as libnftables. This
library is currently used by the nft command line tool.

This release comes with new features available in 3.15, the event
monitoring and fixes for the XML/JSON infrastructure See ChangeLog
for more details.

You can download this library from:

http://www.netfilter.org/projects/libnftnl/downloads.html
ftp://ftp.netfilter.org/pub/libnftnl/

Have fun!

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnftnl-1.0.2.txt"

Ana Rey (76):
      expr: log: Code refactoring in nft_rule_expr_log_snprintf
      expr: log: Rename variables in nft_rule_expr_log_json_parse functions
      expr: log: Use nft_rule_expr_set_* in the xml parsing code
      expr: log: Do not print unset values in xml
      expr: log: Do not print unset values in json
      expr: reject: Add nft_rule_expr_reject_snprinf_* functions
      expr: reject: Use nft_rule_expr_set_* in the xml
      expr: reject: Do not print unset values in xml
      expr: reject: Convert the type of a variable
      expr: reject: Do not print unset values in json
      tests: xmlfile: Remove unset child elements in the log expression
      src: set: Use nft_rule_expr_set_* in the xml parsing code
      tests: nft-parsing-test: Display error reason when testing XML
      src: set: Do not print unset values in xml
      src: set: Do not print unset values in json
      set: Free memory in the same function that is reserved
      tests: xmlfiles: Test files without unset child elements in set elements
      expr: queue: Add nft_rule_expr_queue_snprinf_* functions
      expr: queue: Use nft_rule_expr_* in the xml
      expr: queue: Do not print unset values in xml
      expr: queue: Do not print unset values in json
      expr: queue: Use the correct data type
      expr: queue: Use snprintf and SNPRINTF_BUFFER_SIZE in snprintf_default function
      tests: Add json and xml test file for queue
      expr: nat: Use nft_rule_expr_set_* in the xml
      expr: nat: Do not print unset values in xml file
      expr: nat: Do not print unset values in json file
      expr: limit: Add nft_rule_expr_limit_snprinf_* functions
      expr: limit: Use nft_rule_expr_set_* in the xml parsing code
      expr: limit: Do not print unset values in json
      expr: limit: Do not print unset values in xml
      expr: bitwise: Get a nft_rule_expr type in nft_rule_expr_bitwise_snprintf_* functions
      expr: bitwise: Do not print unset values in xml
      expr: bitwise: Do not print unset values in json
      expr: immediate: Use nft_rule_expr_set_* in the xml parsing code
      expr: immediate: Do not print unset values in json file
      expr: immediate: Do not print unset values in xml file
      expr: meta: Use nft_rule_expr_set_* in the xml parsing code
      expr: meta: Do not print unset values in xml file
      expr: meta: Do not print unset values in json file
      expr: payload: Use nft_rule_expr_set_* in the xml parsing code
      expr: payload: get a nft_rule_expr type in nft_rule_expr_payload_snprintf_* functions.
      expr: payload: Do not print unset values in xml file
      expr: payload: Do not print unset values in json file
      expr: target: get a nft_rule_expr type in nft_rule_expr_target_snprintf_* functions
      expr: target: Use nft_rule_expr_set_* in the xml parsing code
      expr: target: Do not print unset values in xml file
      expr: target: Do not print unset values in json file
      expr: byteorder: Get a nft_rule_expr type in nft_rule_expr_byteorder_snprintf_* functions
      expr: byteorder: Use nft_rule_expr_set_* in the xml parsing code
      expr: byteorder: Do not print unset values in xml file
      expr: byteorder: Rename variables in nft_rule_expr_byteorder_json_parse functions
      expr: byteorder: Do not print unset values in json
      expr: cmp: Get a nft_rule_expr type in nft_rule_expr_cmp_snprintf_* functions
      expr: cmp: Use nft_rule_expr_set_* in the xml parsing code
      expr: cmp: Do not print unset values in xml file
      expr: cmp: Do not print unset values in json file
      expr: ct: Use nft_rule_expr_set_* in the xml parsing code
      expr: ct: Do not print unset values in xml file
      expr: ct: Delete the last comma character in json text
      expr: ct: Do not parse unset values in json
      expr: counter: Add nft_rule_expr_counter_snprinf_* functions
      expr: counter: Use nft_rule_expr_set_* in the xml parsing code
      expr: counter: Do not print unset values in xml
      expr: counter: Do not print unset values in json
      expr: exthdr: Add nft_rule_expr_exthdr_snprinf_* functions
      expr: exthdr: Use nft_rule_expr_set_* in the xml parsing code
      expr: exthdr: Do not print unset values in xml
      expr: exthdr: Do not print unset values in json
      expr: lookup: Use nft_rule_expr_set_* in the xml parsing code
      expr: lookup: Do not print unset values in xml file
      expr: lookup: Do not print unset values in json file
      expr: match: get a nft_rule_expr type in nft_rule_expr_match_snprintf_* functions
      expr: match: Use nft_rule_expr_set_* in the xml parsing code
      expr: match: Do not print unset values in xml file
      expr: match: Do not print unset values in json file

Arturo Borrero (8):
      src: add flag to add event wrapping in output functions
      examples: nft-events: use new events wrappers
      common: fix unconditional output of event wrapping stuff
      ruleset: fix erroneous call to snprintf
      data_reg: fix bad buffer size bounds
      internal: fix SNPRINTF_BUFFER_SIZE macro
      utils: fix buffer reallocation of nft_fprinft()
      expr: nat: add helper function to translate nat types to string

Gustavo Zacarias (1):
      configure: uclinux is also linux (nommu)

Pablo Neira Ayuso (8):
      tests: include test-script.sh via make distcheck
      tests: include xml and json test files via make distcheck
      examples: nft-events: add option how to format the printed events
      include: synchronize nf_tables.h with nftables tree
      set: add set ID support
      common: homogeneous error message in nft_parse_perror()
      expr: remove alignment through XT_ALIGN in match and target
      bump version to 1.0.2

Tomasz Bursztyka (1):
      meta: Add support for input and output bridge interface name


--X1bOJ3K7DJ5YkBrT--
