From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 17:17:13 +0200
Message-ID: <4C5832F9.50004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080507090703060702010009"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080507090703060702010009
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.9

the iptables release for the 2.6.35 kernel. Changes include:

- support for the LED target, which hadn't been merged so far because
  the kernel module had some bugs

- a new version of the set extension for the upcoming release supporting
  IPv6

- negation support for the quota match

- support for the SACK-IMMEDIATELY SCTP extension and FORWARD_TSN
  chunk type in the sctp match

- documentation updates and various smaller bugfixes

See the Changelog for more details.

Version 1.4.9 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!



--------------080507090703060702010009
Content-Type: text/plain;
 name="changes-iptables-1.4.9.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="changes-iptables-1.4.9.txt"

Adam Nielsen (1):
      extensions: add the LED target

Eric Dumazet (1):
      extensions: REDIRECT: add random help

Jan Engelhardt (10):
      utils: add missing include flags to Makefile
      doc: xt_string: correct copy-and-pasting in manpage
      doc: xt_hashlimit: fix a typo
      doc: xt_LED: nroff formatting requirements
      includes: sync header files from Linux 2.6.35-rc1
      xtables: another try at chain name length checking
      xtables: remove xtables_set_revision function
      libxt_hashlimit: always print burst value
      libxt_conntrack: do print netmask
      xt_quota: also document negation

Jozsef Kadlecsik (1):
      libxt_set: new revision added

Luciano Coelho (2):
      extensions: libxt_rateest: fix typo in the man page
      extensions: libxt_rateest: fix bps options for iptables-save

Patrick McHardy (5):
      Revert "Revert "Merge branch 'iptables-next'""
      Merge branch 'master' of git://dev.medozas.de/iptables
      Merge branch 'master' of git://dev.medozas.de/iptables
      Merge branch 'master' of vishnu.netfilter.org:/data/git/iptables
      Bump version to 1.4.9

Samuel Ortiz (1):
      extensions: libxt_quota.c: Support option negation

Shan Wei (2):
      xt_sctp: Trace DATA chunk that supports SACK-IMMEDIATELY extension
      xt_sctp: support FORWARD_TSN chunk type


--------------080507090703060702010009--
