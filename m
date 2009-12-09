From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.6
Date: Wed, 09 Dec 2009 15:48:08 +0100
Message-ID: <4B1FB8A8.10505@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040609050500060703000306"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040609050500060703000306
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.6

the iptables release for the 2.6.32 kernel. Changes include:

- manpage updates

- multiple smaller fixes for xt_iprange, xt_conntrack, iptables
  rule deletion and replacement, inverted argument parsing

- addition of the xt_osf extension

- code cleanups

See the changelog for more details.

Version 1.4.6 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------040609050500060703000306
Content-Type: text/plain;
 name="changes-iptables-1.4.6.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.6.txt"

Jan Engelhardt (20):
      iptables: manpage updates for augmented -Z syntax
      doc: mention maximum mark size in manpages
      Support for nommu arches
      realm: remove static initializations
      libiptc: remove unused functions
      libiptc: avoid strict-aliasing warnings
      iprange: do accept non-ranges for xt_iprange v1
      iprange: warn on reverse range
      iprange: roll address parsing into a loop
      iprange: do accept non-ranges for xt_iprange v1 (log)
      iprange: warn on reverse range (log)
      libiptc: fix wrong maptype of base chain counters on restore
      iptables: fix undersized deletion mask creation
      style: reduce indent in xtables_check_inverse
      libxtables: hand argv to xtables_check_inverse
      iptables/extensions: make bundled options work again
      CONNMARK: print mark rules with mask 0xffffffff as set instead of xset
      iptables: take masks into consideration for replace command
      doc: explain experienced --hitcount limit
      doc: name resolution clarification

Mohit Mehta (1):
      iptables: expose option to zero packet/byte counters for a specific rule

Olaf Rempel (1):
      build: restore --disable-ipv6 functionality on system w/o v6 headers

Patrick McHardy (7):
      Merge branch 'zero' of git://dev.medozas.de/iptables
      MARK: print mark rules with mask 0xffffffff as --set-mark instead of --set-xmark
      DNAT: fix incorrect check during parsing
      extensions: add osf extension
      conntrack: fix --expires parsing
      Merge branch 'master' of git://dev.medozas.de/iptables
      Bump version to v1.4.6

Tim Small (1):
      doc: update TCPMSS manpage with Linux 2.6.25 changes

sobtwmxt (1):
      doc: fix typo in length manpage


--------------040609050500060703000306--
