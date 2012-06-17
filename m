From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] ulogd 2.0.0 release
Date: Sun, 17 Jun 2012 14:07:23 +0200
Message-ID: <20120617120723.GA23082@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        ulogd 2.0.0

ulogd is a userspace logging daemon for netfilter/iptables related
logging. This includes per-packet logging of security violations,
per-packet logging for accounting, per-flow logging and flexible
user-defined accounting.

ulogd was almost entirely written by Harald Welte, with contributions
from fellow hackers such as Pablo Neira Ayuso, Eric Leblond and Pierre
Chifflier.

ulogd-2.x requires several libraries:

* libnfnetlink that provides basic communication infrastructure via
  Netlink.

* libmnl that provides basic communication infrastructure via
  Netlink, this library will supersede libnfnetlink. Still, we require
  both libraries as we are still in transition to entirely replace
  libnfnetlink by libmnl.

* libnetfilter_log for stateless packet-based logging via nfnetlink_queue.

* libnetfilter_conntrack for stateful flow-based via nf_conntrack_netlink.

* libnetfilter_acct for flexible traffic accounting via nfnetlink_acct
  and iptables nfacct match (it requires Linux kernel >= 3.3.x).

This requires a Linux kernel >= 2.6.14, but Linux kernel >= 2.6.18 is
strongly recommended. Note that if you need SQL database output
suport, you will need the header files of the respective libraries.

Main features are:

* Packet and flow-based traffic accounting
* Flexible user-defined traffic accounting via nfacct infrastructure
* SQL database back-end support: SQLite3, MySQL and PostgreSQL
* Text-based output formats: CSV, XML, Netfilter's LOG, Netfilter's
  conntrack.

This releases supersedes 1.x series. Please, upgrade to 2.x series!

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-ulogd-2.0.0.txt"
Content-Transfer-Encoding: 8bit

Björn Lässig (2):
      build: use pkglibdir instead of pkglibexecdir for automake
      doc: add documentation for SIGUSR2

Eric Leblond (8):
      Mysql schema: fix delimiter
      Mysql schema: fix procedure declaration
      ulogd.conf: fix mysql definition for NFCT
      autoconf: fix sqlite configure description message.
      HWHDR: Fix various crashes
      DB output: fix crash in SIGHUP handling
      pcap: fix build on some recent x86_64 platform
      pcap: add file option to configuration file

Harald Welte (1):
      ulogd2 / DBI / table name

Jan Andres (1):
      pcap: fix packet length handling

Jan Engelhardt (20):
      build: move global automake options into configure.ac
      build: remove statements without obvious effect
      build: remove -fPIC flag
      build: remove unused $(all_includes)
      output/LOGEMU: resolve build warning
      build: default to not building static libraries
      build: propagate global CFLAGS
      build: no need for error message in PKG_CHECK_MODULES
      filter/HWHDR: remove redundant sizeof(char)
      build: avoid use of LIBS variable
      build: use appropriate location for program modules
      build: use compile/link information from pkgconfig
      build: simplify sqlite3 check
      build: abort autogen on subcommand failure
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      build: disable implicit .tar.gz archive generation and use POSIX mode
      sqlite: resolve compiler warnings
      nfacct: resolve build failure
      pcap: resolve unreliable detection

Jozsef Kadlecsik (2):
      Support stored mysql procedures besides stored functions
      A simple filter plugin called IP2HBIN added

Pablo Neira Ayuso (20):
      NFCT: fix bug in polling mode
      ulogd: fix double call of stop for reused input plugins
      config: add file option for NACCT pluging to the example config file
      sqlite3: initial support extracted from Holger Eitzenberger's work
      sqlite3: add configuration examples and new tables layout
      NFCT: use nfct_copy() instead of deprecated nfct_sizeof() function
      NFLOG: don't display overrun message once we have reach the buffer limit
      sqlite3: use continue instead of goto in sqlite3_interp()
      sqlite3: cleanup error handling of sqlite3_bind_int() in sqlite3_interp()
      sqlite3: fix warning during compilation
      sqlite3: remove automatic creation of table `daily'
      build: Linux kernel-style for compilation messages
      ulogd: add okey_set_u64
      OPRINT: display u64 fields
      output: add GPRINT plugin
      input: add nfacct plugin
      src: add example use of GPRINT to ulogd.conf.in configuration file
      NFCT: add `reliable' config option to enable reliable flow-based logging
      build: bump release version to 2.0.0
      build: require 1.0.0 of all libraries

Pierre Chifflier (2):
      Add new input plugin UNIXSOCK
      Add helper script pcap2ulog

Salih Gonullu (1):
      ulogd: fix segfault if syslog and SIGTERM is received


--G4iJoqBmSsgzjUCe--
