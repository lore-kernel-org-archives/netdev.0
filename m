From: Patrick McHardy <kaber@trash.net>
Subject: : Release of iptables-1.4.5
Date: Mon, 14 Sep 2009 19:05:11 +0200
Message-ID: <4AAE77C7.200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000005020408020500020003"
To: Netfilter Development Mailinglist <netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter
Return-path: <netfilter-announce-bounces@lists.netfilter.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-announce>,
	<mailto:netfilter-announce-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <http://lists.netfilter.org/pipermail/netfilter-announce>
List-Post: <mailto:netfilter-announce@lists.netfilter.org>
List-Help: <mailto:netfilter-announce-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-announce>,
	<mailto:netfilter-announce-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-announce-bounces@lists.netfilter.org
Errors-To: netfilter-announce-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000005020408020500020003
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.5

the iptables release for the 2.6.31 kernel. Changes include:

- support for nfnetlink_queue queue balancing

- support for revision 2 of the conntrack match, which fixes a
  regression in state matching

- support for multiple IP address specifications with -s/-d

- various internal cleanups and improvements

- manpage updates

Version 1.4.5 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!


--------------000005020408020500020003
Content-Type: text/plain;
 name="changes-iptables-1.4.5.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.5.txt"

Florian Westphal (1):
      libxt_NFQUEUE: add new v1 version with queue-balance option

Jan Engelhardt (18):
      xt_conntrack: revision 2 for enlarged state_mask member
      libxt_helper: fix invalid passed option to check_inverse
      libiptc: split v4 and v6
      extensions: collapse registration structures
      iptables: allow for parse-less extensions
      iptables: allow for help-less extensions
      extensions: remove empty help and parse functions
      xtables: add multi-registration functions
      extensions: collapse data variables to use multi-reg calls
      xtables: warn of missing version identifier in extensions
      COMMIT_NOTES: notice to check for soversion bumps
      build: order of dependent libs is sensitive
      multi binary: allow subcommand via argv[1]
      build: fix struct size mismatch
      build: combine iptables-multi and iptables-static
      build: build only iptables-multi
      Merge branch 'stable'
      manpages: more fixes to minuses, hyphens, dashes

Laurence J. Lane (1):
      manpage: fix lintian warnings

Michael Granzow (1):
      iptables: accept multiple IP address specifications for -s, -d

Patrick McHardy (2):
      man: fix incorrect plural in libipt_set.man
      Bump version number to 1.4.5

Trent W. Buck (1):
      ipt_set: fix a typo in the manpage


--------------000005020408020500020003--
