From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.2.0 release
Date: Sat, 26 May 2012 20:06:54 +0200
Message-ID: <20120526180654.GB31938@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GRPZ8SYKNexpdSJ7"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59808 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab2EZSG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2012 14:06:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.2.0

This release is a major milestone that includes support for
expectation synchronization and the new nfct utility that, by now,
only supports the new cttimeout infrastructure.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/conntrack-tools/downloads.html
ftp://ftp.netfilter.org/pub/conntrack-tools/

Have fun!

--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.2.0.txt"

Adrian Bridgett (1):
      src: manpage and help display improvements

Florian Westphal (1):
      conntrack: flush stdout for each expectation event, too

Pablo Neira Ayuso (34):
      conntrackd: generalize caching infrastructure
      conntrackd: generalize external handlers to prepare expectation support
      conntrackd: generalize/cleanup network message building/parsing
      conntrackd: generalize local handler actions
      conntrackd: simplify cache_get_extra function
      conntrackd: remove cache_data_get_object and replace by direct pointer
      conntrackd: constify ct parameter of ct_filter_* functions
      conntrackd: relax checkings in ct_filter_sanity_check
      conntrackd: minor cleanup for commit
      conntrackd: support for expectation synchronization
      doc: update conntrack-tools manual to detail expectation support
      conntrackd: fix expectation filtering if ExpectationSync On is used
      conntrack: add expectation support for `-o' option
      conntrackd: support `-i exp -x' and `-e exp -x' options
      conntrack: fix setting fixed-timeout status flag
      conntrackd: add support expectation class synchronization
      conntrackd: add NAT expectation support
      conntrackd: add support to synchronize helper name
      conntrackd: support expectfn synchronization for expectations
      conntrackd: fix parsing of expectation class, helper name and NAT
      conntrack: allow to filter by mark from kernel-space
      conntrackd: allow using lower/upper case in ExpectationSync
      doc: add ras, q.931 and h.245 to examples configuration file
      doc: fix example on how to filter events via iptables CT target
      icmp[v6]: --icmp[v6]-[type|code] are optional for updates and deletes
      src: integrate nfct into the conntrack-tools tree
      tests: add nfct tests for cttimeout
      build: bump version to 1.2.0
      nfct: fix compilation warning in cttimeout support
      build: update dependencies with libnetfilter_conntrack (>= 1.0.1)
      move qa directory to tests/conntrack/
      tests: conntrack: add run-test.sh script
      add nfct(8) manpage
      add README.nfct


--GRPZ8SYKNexpdSJ7--
