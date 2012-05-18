From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_conntrack 1.0.1 release
Date: Fri, 18 May 2012 02:35:47 +0200
Message-ID: <20120518003547.GA11232@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_conntrack 1.0.1

libnetfilter_conntrack is a userspace library providing a programming
interface (API) to the in-kernel connection tracking state table.
This library is currently used by conntrack-tools among many other
applications.

This release includes important improvements for the expectation
support.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_conntrack/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_conntrack/

Have fun!

--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_conntrack-1.0.1.txt"

Kelvie Wong (1):
      expect: support NFCT_Q_CREATE_UPDATE in nfexp_query

Pablo Neira Ayuso (15):
      expect: add XML support for nfexp_snprintf()
      expect: add class support
      expect: add NAT support
      expect: add expectfn support
      expect: CTA_EXPECT_HELP_NAME must be NULL-terminated
      expect: fix comparison of expectation class and flags
      expect: fix missing whitespace after expectation flags in nfexp_snprintf
      conntrack: add support for CTA_MARK_MASK and filtered dumping
      qa: add some stress tools to test conntrack via ctnetlink
      qa: several improvements for the ct_stress tools
      conntrack: fix wrong building of ICMP reply tuple
      conntrack: add new ATTR_GRP_[ORIG|REPL]_ADDR_[SRC|DST] attribute
      conntrack: fix new ATTR_GRP_[ORIG|REPL]_ADDR_[SRC|DST]
      qa: add test case for get/set ATTR_GRP_* API
      build: bump version to 1.0.1


--UugvWAfsgieZRqgk--
