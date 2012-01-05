From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.0.1 release
Date: Thu, 5 Jan 2012 11:35:09 +0100
Message-ID: <20120105103509.GB7046@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IiVenqGWf+H9Y6IX"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.0.1

The conntrack-tools are a set of tools targeted at system
administrators. They are conntrack, the userspace command line
interface, and conntrackd, the userspace daemon. The tool conntrack
provides a full featured interface that is intended to replace the old
/proc/net/ip_conntrack interface. Using conntrack, you can view and
manage the in-kernel connection tracking state table from userspace.
On the other hand, conntrackd covers the specific aspects of stateful
firewalls to enable highly available scenarios.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/conntrack-tools/downloads.html
ftp://ftp.netfilter.org/pub/conntrack-tools/

Have fun!

--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.0.1.txt"

Florian Westphal (4):
      conntrack: add support for mark mask
      conntrack: skip sending update message to kernel if conntrack is unchanged
      testsuite: add tests for --mark option
      conntrack: add missing break when parsing --id/--secmark options

Jan Engelhardt (3):
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode

Pablo Neira Ayuso (8):
      build: Linux kernel-style for compilation messages
      conntrack: remove unused variable with -S
      conntrackd: add missing initial caching of gettimeofday()
      conntrackd: fix filtering of dump output if internal cache is disabled
      Merge branch 'master' of git://dev.medozas.de/conntrack-tools
      doc: primary-backup.sh: clarify licensing terms (GPLv2+)
      conntrackd: fix checking of return value of queue_add()
      build: bump version to 1.0.1


--IiVenqGWf+H9Y6IX--
