From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnftnl 1.0.1 release
Date: Thu, 17 Apr 2014 13:09:08 +0200
Message-ID: <20140417110908.GA23125@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnftnl 1.0.1

libnftnl is a userspace library providing a low-level netlink
programming interface (API) to the in-kernel nf_tables subsystem. The
library libnftnl has been previously known as libnftables. This
library is currently used by the nft command line tool.

This release comes with new features available in 3.14 and fixes.
See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnftnl/downloads.html
ftp://ftp.netfilter.org/pub/libnftnl/

Have fun!

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-libnftnl-1.0.1.txt"
Content-Transfer-Encoding: 8bit

Ana Rey (9):
      tests: Use getopt_long to parse the command-line arguments.
      xml, json: Delete a cmpdata label in xml and json file
      xml, json: Delete an immediatedate label in xml and json file
      tests: New tools to update xml and json testfiles
      tests: Add support to check a json or xml testfile
      tests: Fix a memory leak
      target, match: Fix an invalid read
      set-elem: fix a memory leak
      lookup: Fix an invalid read

Arturo Borrero (8):
      src: update meta expr
      examples: nft-set-get: retrieve all sets via unspec
      examples: add nft-ruleset-get
      include: add stdint.h to common.h
      src: check if netlink parsing fails
      set_elems: delete unexisting exported symbol
      set_elem: parse family from Netlink message
      examples: complete nft-events example

Arturo Borrero Gonzalez (1):
      tests: add table 'use' attr to testfiles

Eric Leblond (2):
      expr: add support for nfnetlink queue
      test: add tests for expr queue

Florian Westphal (1):
      expr: add conntrack label match support

Jan Engelhardt (2):
      build: resolve build failure involving linux/netlink.h
      build: resolve compile error involving XT_EXTENSION_MAXNAMELEN

Kristian Evensen (2):
      meta: Let user specify any combination of sreg/dreg
      expr: ct: Add support for setting the mark

Pablo Neira Ayuso (17):
      src: fix compilation due to missing NFPROTO_INET definition
      build: fix final report after configuration
      include: add cached copy of linux/kernel.h
      Merge branch 'master' into next-3.14
      chain: print usage counter for base chain via default output as well
      src: compile queue expression support
      src: early attribute type validation in nft_*_attr_set
      src: add assertion infrastructure to validate attribute types
      src: add nft_*_attr_{set|get}_data interface
      src: fix wrong type in NFT_ATTR_*_FAMILY
      include: get linux/netfilter/nf_tables.h in sync with kernel header
      example: nft-rule-add: simplify example
      rule: add NFT_RULE_ATTR_USERDATA support
      examples: remove nft-rule-insert from Makefile.am
      src: fix bogus assertion for unset attributes
      include: add missing netfilter.h
      bump version to 1.0.1

Patrick McHardy (4):
      libnftables: add support for inet family and mete nfproto/l4proto expressions
      Merge branch 'next-3.14' of git.netfilter.org:libnftables into inet
      libnftables: replace netfilter.h by sanitized header
      expr/cmp: fix type size

Tomasz Bursztyka (2):
      table: Add support for NFTA_TABLE_USE attribute
      build: Ensure pkg-config file provides the right informations

Álvaro Neira Ayuso (5):
      examples: nft-rule-del: fix missing batching headers
      examples: nft-rule-insert: fix and merge it to nft-rule-add
      examples: nft-rule-del: removed printf rule function
      rule: don't print unset attributes
      rule: don't enforce attributes when parsing


--IS0zKkzwUGydFO0o--
