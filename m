From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.4.0 release
Date: Mon, 8 Oct 2012 13:50:21 +0200
Message-ID: <20121008115021.GA26222@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.4.0

This release adds the user-space helper infrastructure which includes
the RPC portmapper (to support NFSv3) and Oracle*TNS helpers.

More information available at:

http://conntrack-tools.netfilter.org/manual.html

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/conntrack-tools/downloads.html
ftp://ftp.netfilter.org/pub/conntrack-tools/

Have fun!

--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.4.0.txt"

Ansis Atteka (1):
      tests: conntrackd: fix compile errors and warnings

Jozsef Kadlecsik (2):
      conntrackd: RPC helper added to cthelper
      conntrackd: TNS helper added to cthelper

Nicolas Dichtel (1):
      build: fix libraries dependencies in Makefiles

Pablo Neira Ayuso (14):
      conntrack: add support for stats dumping via ctnetlink
      conntrack: -C uses ctnetlink instead of /proc/sys/net/netfilter/nf_conntrack_count
      conntrackd: generalize file descriptor infrastructure
      conntrackd: move ctnetlink code to ctnl.c (removed from run.c)
      conntrackd: add cthelper infrastructure (+ example FTP helper)
      tests: conntrackd: add cthelper-test infrastructure
      nfct: helper: use CONNTRACKD_LIB_DIR variable set during configuration
      cthelper: disable debugging information by default
      cthelper: ftp: fix EPRT case for IPv4
      conntrackd: parse: fix wrong maximum length for ATTR_EXP_FN
      conntrackd: cthelper: add QueueLen option
      conntrackd: fix crash if ExpectationSync is enabled on old Linux kernels
      doc: detail user-space helper support
      bump version to 1.4.0 and update dependencies

Vincent Bernat (1):
      conntrackd: don't resync expectations if such sync has been disabled


--1yeeQ81UyVL57Vl7--
