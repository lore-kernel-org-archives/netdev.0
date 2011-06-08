From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.11.1
Date: Wed, 08 Jun 2011 15:54:01 +0200
Message-ID: <4DEF7EF9.7010609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070206020401010904020204"
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070206020401010904020204
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.11.1

a minor release containing bugfixes for problems discovered in
the 1.4.11 release as well as some minor documentation updates.

Due to the large number of changes in 1.4.11, some regressions
and a few minor bugs made it into the release. This version
addresses all identified problems:

- broken inversion support in the owner match

- broken inversion in implicitly loaded protocol extensions, most
  importantly causing "-p tcp ! --syn" to not negate --syn

- symlink installation fixes

- xml translation missing in IPv6 only builds

See the attached changelogs for the full list of changes.

Version 1.4.11.1 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------070206020401010904020204
Content-Type: text/plain;
 name="changes-iptables-1.4.11.1.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="changes-iptables-1.4.11.1.txt"

Elie De Brauwer (1):
      doc: fix trivial typo in libipt_SNAT

Jan Engelhardt (13):
      libxt_owner: restore inversion support
      build: remove dead code parts
      build: fix installation of symlinks
      build: fix absence of xml translator in IPv6-only builds
      doc: update GPL license text
      doc: iptables-xml should be in manpage section 1
      build: move basic preprocessor flags to regular_CPPFLAGS
      build: move kinclude's preprocessor flags to kinclude_CPPFLAGS
      src: move all libiptc pieces into its directory
      src: move all iptables pieces into a separate directory
      tests: add some sample rulesets to test save-restore cycle
      option: fix ignored negation before implicit extension loading
      build: re-add missing CPPFLAGS for libiptc

Maciej Żenczykowski (1):
      xtables-multi: fix absence of xml translator in IPv6-only builds

Mike Frysinger (1):
      build: move remaining preprocessor flags to CPPFLAGS

Patrick McHardy (1):
      Bump version to 1.4.11.1

Vlad Dogaru (1):
      doc: fix MASQUERADE section of man page


--------------070206020401010904020204--
