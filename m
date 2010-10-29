From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.10
Date: Fri, 29 Oct 2010 17:43:06 +0200
Message-ID: <4CCAEB8A.5090504@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020503020803020608050505"
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'" <netfilter
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020503020803020608050505
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.10

the iptables release for the 2.6.36 kernel. Changes include:

- support for the cpu match, which can be used to improve cache
  locality when running multiple server instances

- support for the IDLETIMER target, which can be used to notify
  userspace of interfaces being idle

- support for the CHECKSUM target

- support for the ipvs match

- documentation updates

- a fix for deletion of rules using the quota match

See the Changelog for more details.

Version 1.4.10 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------020503020803020608050505
Content-Type: text/plain;
 name="changes-iptables-1.4.10.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="changes-iptables-1.4.10.txt"

Changli Gao (1):
      libxt_quota: don't ignore the quota value on deletion

Eric Dumazet (2):
      extensions: REDIRECT: add random help
      extension: add xt_cpu match

Hannes Eder (1):
      libxt_ipvs: user-space lib for netfilter matcher xt_ipvs

Jan Engelhardt (11):
      doc: let man(1) autoalign the text in xt_cpu
      doc: remove extra empty line from xt_cpu
      doc: minimal spelling updates to xt_cpu
      all: consistent syntax use in struct option
      doc: consistent use of markup
      xtables: remove unnecessary cast
      build: fix static linking
      iptables-xml: resolve compiler warnings
      iptables: limit chain name length to be consistent with targets
      libiptc: build with -Wl,--no-as-needed
      libiptc: add Libs.private to pkgconfig files

Luciano Coelho (2):
      extensions: add idletimer xt target extension
      extensions: libxt_IDLETIMER: use xtables_param_act when checking options

Michael S. Tsirkin (1):
      extensions: libxt_CHECKSUM extension

Patrick McHardy (6):
      extensions: libipt_LOG/libip6t_LOG: support macdecode option
      extensions: fix compilation of the new CHECKSUM target
      Merge branch 'master' into iptables-next
      Merge branch 'master' into iptables-next
      Merge branch 'iptables-next'
      Bump version to 1.4.10


--------------020503020803020608050505--
