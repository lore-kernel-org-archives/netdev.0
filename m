From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.16 release
Date: Mon, 8 Oct 2012 00:24:41 +0200
Message-ID: <20121007222441.GA2976@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ikeVEW9yuYc//A+q"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.16

This release includes minor bugfixes, improvements and the aliasing
support that allows us to remove superseded matches/targets in the
Linux kernel.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="changes-iptables-1.4.16.txt"
Content-Transfer-Encoding: 8bit

Andreas Schwab (1):
      libxt_tcp: print space before, not after "flags:"

Jan Engelhardt (23):
      iptables-restore: warn about -t in rule lines
      doc: grammatical updates to libxt_SET
      libxt_u32: do bounds checking for @'s operands
      libxt_devgroup: consolidate devgroup specification parsing
      libxt_devgroup: guard against negative numbers
      libxt_LED: guard against negative numbers
      libxt_*limit: avoid division by zero
      Merge remote-tracking branch 'nf/stable'
      build: support for automake-1.12
      build: separate AC variable replacements from xtables.h
      build: have `make clean` remove dep files too
      libxtables: consolidate preference logic
      iptables: support for target aliases
      libxt_NOTRACK: replace as an alias to CT --notrack
      iptables: support for match aliases
      libxt_state: replace as an alias to xt_conntrack
      Merge branch 'master' of git://git.inai.de/iptables
      doc: clean up interpunction in state list for xt_conntrack
      doc: deduplicate extension descriptions into a new manpage
      doc: trim "state" manpage and reference conntrack instead
      doc: have NOTRACK manpage point to CT instead
      doc: mention iptables-apply in the SEE ALSO sections
      Merge branch 'master' of git://git.inai.de/iptables

Jozsef Kadlecsik (1):
      New set match revision with --return-nomatch flag support

Michal Kubeček (1):
      libip6t_frag: match any frag id by default

Pablo Neira Ayuso (6):
      include: add missing linux/netfilter_ipv4/ip_queue.h
      ip[6]tables-restore: cleanup to reduce one level of indentation
      include: add missing linux/netfilter_ipv4/ip_queue.h
      iptables: fix wrong error messages
      extensions: libxt_addrtype: fix type in help message
      bump version to 1.4.16


--ikeVEW9yuYc//A+q--
