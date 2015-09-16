From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnftnl 1.0.4 release
Date: Wed, 16 Sep 2015 13:50:04 +0200
Message-ID: <20150916115004.GA1102@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnftnl 1.0.4

libnftnl is a userspace library providing a low-level netlink
programming interface (API) to the in-kernel nf_tables subsystem. The
library libnftnl has been previously known as libnftables. This
library is currently used by the nft command line tool.

This release comes with new features available up to 4.2, see
ChangeLog for more details.

In this release, we have renamed most of the library symbols to use
the nftnl_ prefix while keeping aliases to the old ones. We would like
to reserve the nft_ prefix for our higher level library which should
land anytime soon. We have kept aliases around to reduce the impact of
this changes, but they will be deprecated soon. Sorry for the
inconvenience in any case.

You can download this library from:

http://www.netfilter.org/projects/libnftnl/downloads.html
ftp://ftp.netfilter.org/pub/libnftnl/

Thanks!

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-libnftnl-1.0.4.txt"
Content-Transfer-Encoding: 8bit

Alvaro Neira (12):
      ruleset: clean up the variable names in the xml/json parsing functions
      src: don't create iterator with empty list
      ruleset: refactor nft_ruleset_*_parse_ruleset()
      set: refactor code in json parse function
      rule: don't release the tree parameter from nft_jansson_parse_rule()
      ruleset: fix leak in json/xml in set lists
      ruleset: fix crash if we free sets included in the set_list
      ruleset: crash from error path when we build the xml/json tree
      xml: test if the root node name is initialized
      examples: add nft-ruleset-parse-file
      ruleset: add nft_ruleset_ctx_free
      parser: Add operation not supported error message

Alvaro Neira Ayuso (4):
      buffer: fix missing XML string tag in nft_buf_close
      src: add command tag in JSON/XML export support
      src: add support to import JSON/XML with the new command tag
      tests: update JSON/XML tests with the new syntax

Arturo Borrero Gonzalez (1):
      expr: dynset: fix json/xml parsing

Balazs Scheidler (1):
      expr: redir: fix snprintf to return the number of bytes printed

Carlos Falgueras García (1):
      src: fix memory leaks at nft_[object]_nlmsg_parse

Pablo Neira Ayuso (17):
      src: add missing include in utils.c
      ruleset: fix more leaks in error path
      src: split internal.h is smaller files
      Makefile: internal.h now resides in include
      src: restore static array with expression operations
      src: add batch abstraction
      table: add netdev family support
      chain: add netdev family support
      expr: immediate: fix leak in expression destroy path
      src: introduce nftnl_* aliases for all existing functions
      src: rename existing functions to use the nftnl_ prefix
      src: add compat header file definitions
      src: rename nftnl_rule_expr to nftnl_expr
      src: rename NFTNL_RULE_EXPR_ATTR to NFTNL_EXPR_
      src: get rid of _ATTR_ infix in new nfntl_ definitions
      src: get rid of _attr_ infix in new nftnl_ definitions
      bump version to 1.0.4

Patrick McHardy (11):
      list: fix prefetch dummy
      set: add support for set timeouts
      set_elem: add timeout support
      set: print set elem timeout information
      set_elem: add support for userdata
      expr: add support for the dynset expr
      headers: resync headers for new register definitions
      data: increase maximum possible data size
      expr: seperate expression parsing and building functions
      set_elem: support expressions attached to set elements
      dynset: support expression templates


--CE+1k2dSO48ffgeK--
