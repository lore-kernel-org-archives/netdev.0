From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] Netfilter releases: iptables 1.4.13, nfacct 1.0.0 and
 libnetfilter_acct 1.0.0
Date: Tue, 27 Mar 2012 14:17:36 +0200
Message-ID: <20120327121736.GA17708@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.13
	nfacct 1.0.0
	libnetfilter_acct 1.0.0

Changes in iptables include:

* rpfilter support from Florian Westphal.

* IPv6 ECN capable version from Patrick McHardy.

* a couple of fixes for internal libiptc library.

* fix leaking file descriptor to avoid annoying log messsages in SELinux from
  Maciej enczykowski.

* nfacct match support by myself.

For nfacct and libnetfilter_acct, this is the initial release. These require
Linux kernel 3.3 or any later.

You can download all these from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

http://www.netfilter.org/projects/nfacct/downloads.html
ftp://ftp.netfilter.org/pub/nfacct/

http://www.netfilter.org/projects/libnetfilter_acct/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_acct/

You can also find the changelog to this email for more information.

Have fun!

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="changes-iptables-1.4.13.txt"
Content-Transfer-Encoding: 8bit

Florian Westphal (1):
      extensions: add rpfilter module

Franz Flasch (2):
      iptables: missing free() in function cache_add_entry()
      iptables: missing free() in function delete_entry()

Jonh Wendell (1):
      libiptc: Returns the position the entry was inserted

Maciej Żenczykowski (1):
      src: mark newly opened fds as FD_CLOEXEC (close on exec)

Pablo Neira Ayuso (7):
      Revert "libiptc: Returns the position the entry was inserted"
      extensions: add nfacct match
      Bump version to 1.4.13

Patrick McHardy (1):
      extensions: add IPv6 capable ECN match extension

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-nfacct-1.0.0.txt"

Pablo Neira Ayuso (11):
      initial import
      nfacct: use return instead of exit(EXIT_FAILURE)
      build: remove bogus dependencies
      nfacct: check for too many arguments
      nfacct: check for wrong arguments
      nfacct: replace one leftover perror by nfacct_perror
      doc: minor fixes for nfacct.8
      nfacct: fix licensing terms, this is GPLv2 software
      nfacct: add XML output support
      nfacct: update manpage to include xml and reset options
      build: nfacct release 1.0.0


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_acct-1.0.0.txt"

Jan Engelhardt (5):
      build: enable automake warnings
      build: remove unnecessary AC_EXEEXT
      Update .gitignore
      Add examples/.gitignore
      build: add missing LIBMNL_CFLAGS to compilation process

Pablo Neira Ayuso (27):
      intial import of libnetfilter_acct
      fix crash if no data pointer is passed to nfacct_list_cb
      src: improve nfacct-add example
      add missing .gitignore
      add missing Makefile.am files
      update headers to use new nfnetlink subsys
      examples: nfacct-get: display pkt and byte counters
      fix endianness in 64-bits packet and bytes counters
      examples: nfacct-add: initialize counters, otherwise we add garbage
      add README file
      add NFNL_MSG_ACCT_GET_CTRZERO
      examples: add nfacct-del to delete accounting objects
      extend nfacct_list to allow to zero counters
      examples: nfacct-get allows to zero counters with `-z' option
      update nfnetlink_acct.h
      src: major API redesign
      src: add library documentation in doxygen
      add COPYING file and other licensing stuff
      update README file
      build: update configure.ac and gcc4_visibility.m4
      update .gitignore file
      nfacct: modify nfacct_snprint output
      nfacct: use NFACCT_ATTR_* flags in nfacct_nlmsg_build_payload
      nfacct: check if attribute is set in nfacct_attr_get*
      extend README
      nfacct: change prototype of nfacct_snprintf() to support output in XML
      examples: fix nfacct-get example


--2oS5YaxWCcQjTEyO--
