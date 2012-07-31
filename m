From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.15 release
Date: Tue, 31 Jul 2012 13:25:31 +0200
Message-ID: <20120731112531.GA3493@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.15

This release includes support for new features now present in the
Linux kernel 3.5 and one major bugfix (that shows up with gcc-4.7).

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.15.txt"

Denys Fedoryshchenko (1):
      libxt_recent: add --mask netmask

Eldad Zack (1):
      libxt_recent: remove unused variable

Florian Westphal (2):
      libxt_devgroup: add man page snippet
      libxt_hashlimit: add support for byte-based operation

Hans Schillstrom (3):
      extensions: add HMARK target
      libxt_HMARK: fix output of iptables -L
      libxt_HMARK: correct a number of errors introduced by Pablo's rework

Pablo Neira Ayuso (6):
      libxtables: add xtables_ip[6]mask_to_cidr
      libxt_HMARK: fix ct case example
      iptables-restore: move code to add_param_to_argv, cleanup (fix gcc-4.7)
      Revert "iptables-restore: move code to add_param_to_argv, cleanup (fix gcc-4.7)"
      iptables-restore: fix parameter parsing (shows up with gcc-4.7)
      bump version to 1.4.15


--dDRMvlgZJXvWKvBx--
