From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.8
Date: Thu, 20 May 2010 17:08:03 +0200
Message-ID: <4BF55053.7040600@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070008080503000106060800"
Cc: netfilter <netfilter@lists.netfilter.org>,
	netfilter-announce@lists.netfilter.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-core@lists.netfilter.org
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070008080503000106060800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.8

the iptables release for the 2.6.34 kernel. Changes include:

- support for the new CT target
- port parsing fixes in the REDIRECT and MASQUERADE targets
- iprange v0 parsing fixes
- removal of MARK target restriction to the mangle table
- documentation updates
- inclusion of the nfnl_osf program for OS fingerprinting support

See the Changelog for more details.

Version 1.4.8 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------070008080503000106060800
Content-Type: text/plain;
 name="changes-iptables-1.4.8.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.8.txt"

Dmitry V. Levin (3):
      extensions: REDIRECT: fix --to-ports parser
      iptables: add noreturn attribute to exit_tryhelp()
      extensions: MASQUERADE: fix --to-ports parser

Jan Engelhardt (8):
      libxt_comment: avoid use of IPv4-specific examples
      libxt_CT: add a manpage
      iptables: correctly check for too-long chain/target/match names
      doc: libxt_MARK: no longer restricted to mangle table
      doc: remove claim that TCPMSS is limited to mangle
      libxt_recent: add a missing space in output
      doc: add manpage for libxt_osf
      libxt_osf: import nfnl_osf program

Karl Hiramoto (1):
      iptables: optionally disable largefile support

Pablo Neira Ayuso (1):
      CT: fix --ctevents parsing

Patrick McHardy (3):
      extensions: add CT extension
      libxt_CT: print conntrack zone in ->print/->save
      xtables: fix compilation when debugging is enabled

Simon Lodal (1):
      libxt_conntrack: document --ctstate UNTRACKED

Vincent Bernat (1):
      iprange: fix xt_iprange v0 parsing


--------------070008080503000106060800--
