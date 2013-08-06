From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.4.2 release
Date: Tue, 6 Aug 2013 18:55:09 +0200
Message-ID: <20130806165509.GA18035@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.4.2

The conntrack-tools are the userspace command line interface
`conntrack' and the userspace daemon `conntrackd'. The conntrack
utility replaces the old /proc/net/nf_conntrack interface. With
conntrack, you can dump, modify and delete entries from the connection
tracking state table from userspace. On the other hand, conntrackd
allows you to deploy highly available stateful firewall clusters and
to run connection tracking helpers from user-space.

More information in the official manual at:
http://conntrack-tools.netfilter.org/manual.html

This release includes bugfixes and the connlabel support. See ChangeLog that
comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/nfacct/downloads.html
ftp://ftp.netfilter.org/pub/nfacct/

Have fun!

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.4.2.txt"

Clemence Faure (2):
      conntrack: introduce -l option to filter by labels
      conntrack: fix reporting of unknown arguments

Florian Westphal (5):
      conntrackd: fix compiler warnings
      include: kill unused PLD_* macros
      conntrack: add connlabel format attribute
      conntrackd: support replication of connlabels
      conntrack: fix -L format output

James Guthrie (1):
      conntrackd: fix parsing of non-abbreviated IPv6 address in config file

Pablo Neira Ayuso (11):
      build: requires libnetfilter_conntrack >= 1.0.3
      conntrack: fix timestamps when microseconds are less than 100000
      tests: cthelper: remove test infrastructure from this tree
      cthelper: add IPv6 support
      cthelper: helpers may not use private information area
      conntrackd: cache: fix hashing based on IPv6 address
      conntrackd: deprecate `Family' in configuration file
      conntrackd: fix crash with IPv6 expectation in the filtering code
      conntrackd: simplify expectation filtering
      cthelper: fix IPv6 address and mask in newly created expectations
      conntrack-tools 1.4.2 release


--pf9I7BMVVzbSWLtt--
