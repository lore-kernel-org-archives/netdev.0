From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_conntrack 1.0.0 release
Date: Wed, 4 Jan 2012 17:42:57 +0100
Message-ID: <20120104164257.GA3309@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_conntrack-1.0.0

libnetfilter_conntrack is a userspace library providing a programming
interface (API) to the in-kernel connection tracking state table.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_conntrack/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_conntrack/

Have fun!

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_conntrack-1.0.0.txt"

Andrew Beverley (1):
      utils: add nfct_destroy() to all examples in utils

Jan Engelhardt (3):
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode

Jiri Popelka (1):
      conntrack: objopt: NO_EFFECT

Pablo Neira Ayuso (20):
      build: Linux kernel-style for compilation messages
      doc: fix missing nfct_copy function not included in doxygen report
      expect: fix missing parsing of master tuple
      expect: nfexp_snprintf prints expectation timeout if present
      expect: nfexp_snprintf displays mask and master tuple information
      expect: add nfexp_send()
      expect: support CTA_EXPECT_HELP_NAME
      expect: modify output by moving zone and flags to the end of the line
      src: export NFCT_HELPER_NAME_MAX
      utils: fix expect_get to work with expect_create
      Merge branch 'master' of git://dev.medozas.de/libnetfilter_conntrack
      src: clarify licensing terms of library (GPLv2+)
      conntrack: fix size of CTA_PROTOINFO_TCP_FLAGS_ORIGINAL in ARM
      include: remove reference to licensing terms from headers
      src: put nf_expect and nf_conntrack into diet
      qa: extend test_api to validate set API for conntrack objects
      conntrack: fix set operation for master IPv6 src and dst
      expect: extend test_api for the expectation API
      expect: add nfexp_cmp
      build: bump version to 1.0.0


--+HP7ph2BbKc20aGI--
