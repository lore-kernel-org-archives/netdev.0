From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_conntrack 1.0.4 release
Date: Tue, 6 Aug 2013 17:45:21 +0200
Message-ID: <20130806154521.GA14118@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="O5XBE6gyVG5Rl6Rj"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50304 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755712Ab3HFPpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 11:45:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--O5XBE6gyVG5Rl6Rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_conntrack 1.0.4

libnetfilter_conntrack is a userspace library providing a programming
interface (API) to the in-kernel connection tracking state table. This
library is currently used by conntrack-tools and iptables, among other
applications.

This release includes connlabel support, one memleak fix and fixes in
the comparison API. See ChangeLog that comes attached to this email
for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_conntrack/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_conntrack/

Have fun!

--O5XBE6gyVG5Rl6Rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_conntrack-1.0.4.txt"

Afschin Hormozdiary (1):
      libnetfilter_conntrack: don't ignore ATTR_CONNLABELS

Florian Westphal (18):
      api: add nfct_bitmask object
      api: add connlabel api and attribute
      examples: add connlabel dump/set/clear demo programs
      api: add CTA_LABEL_MASK attribute handling
      qa: add api test for nfct_cmp and nfct_exp functions
      conntrack, expect: fix _cmp api with STRICT checking
      expect: consider all expect attributes when comparing
      conntrack: nfct_cmp: also compare labels
      qa: nfct_cmp: verify individual attr comparision
      connlabel: fix NULL deref on malloc failure
      conntrack: CONNLABELS are not a nested attribute
      conntrack: connlabel: remove useless test
      conntrack: labels: skip labels with non-alnum characters
      src: callback: fix memory leak when ct has dynamically allocated attr
      conntrack: api: add nfct_snprintf_labels
      qa: test_connlabel: don't abort when system-wide config exists
      conntrack: labels: labelmap_new: make sure errno is 0 when no labels are found
      build: bump version to 1.0.4


--O5XBE6gyVG5Rl6Rj--
