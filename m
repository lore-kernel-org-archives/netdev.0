From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_cttimeout 1.0.0 release
Date: Sat, 26 May 2012 20:03:17 +0200
Message-ID: <20120526180317.GA31938@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_cttimeout 1.0.0

libnetfilter_cttimeout is the userspace library that provides the
programming interface to the fine-grain connection tracking timeout
infrastructure. With this library, you can create, update and delete
timeout policies that can be attached to traffic flows. This library
is used by conntrack-tools.

To use this library, you require a Linux kernel >= 3.4.0.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_cttimeout/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_cttimeout/

Have fun!

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_cttimeout-1.0.0.txt"

Jan Engelhardt (6):
      Add .gitignore
      const-ify static data objects
      Add stdint header and type corrections
      Properly NUL-terminate name in nfct_timeout_attr_set
      const-ify arguments of functions
      Add extern "C" guard for C++ compilation mode

Pablo Neira Ayuso (11):
      initial commit
      add README file
      This library is licensed under GPLv2+
      Merge branch 'master' of git://dev.medozas.de/libnetfilter_cttimeout
      add nfct_timeout_policy_attr_to_name(state_attr)
      don't add CTA_TIMEOUT_DATA nest if no policy attributes are present
      add missing ICMPv6 support
      src: improvements for the doxygen documentation
      src: add new parameter type to nfct_timeout_snprintf
      src: more minor improvements for the doxygen documentation
      build: fix broken Makefile.am in include/linux/

--Qxx1br4bt0+wmkIi--
