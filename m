From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.14 release
Date: Sat, 26 May 2012 20:15:22 +0200
Message-ID: <20120526181522.GA32109@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.14

This release several bugfixes and support for the new cttimeout
infrastructure. This allows you to attach specific timeout policies to
flow via iptables CT target.

The following example shows the usage of this new infrastructure in a
couple of steps:

1) Create a timeout policy with name `custom-tcp-policy1':

 nfct timeout add custom-tcp-policy1 inet tcp established 200

2) Attach it to traffic going from 1.1.1.1 to 2.2.2.2

iptables -I PREROUTING -t raw -s 1.1.1.1 -d 2.2.2.2 -p tcp \
        -j CT --timeout custom-tcp-policy1

The new nfct resides in the conntrack-tools tree. By now, this new
utility only supports the cttimeout. In the long run, the plan is to
replace the conntrack utility with it.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/conntrack-tools/downloads.html
ftp://ftp.netfilter.org/pub/conntrack-tools/

Have fun!

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.14.txt"

Florian Westphal (3):
      ip(6)tables-restore: make sure argv is NULL terminated
      extensions: libxt_rateest: output all options in save hook
      tests: add rateest match rules

Miguel GAIO (1):
      libiptc: fix retry path in TC_INIT

Pablo Neira Ayuso (3):
      libxt_CT: add --timeout option
      libipt_ULOG: fix --ulog-cprange
      Bump version to 1.4.14


--DocE+STaALJfprDB--
