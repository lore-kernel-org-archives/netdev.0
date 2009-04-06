From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] Release of iptables-1.4.3.2
Date: Mon, 06 Apr 2009 13:38:14 +0200
Message-ID: <49D9E9A6.7010303@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090700010709050000090606"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46064 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755449AbZDFLi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 07:38:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090700010709050000090606
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

     iptables version 1.4.3.2

the iptables release for the 2.6.29 kernel. This version includes
accumulated bugfixes for the previous release from Jan Engelhardt and
Peter Volkov. Check the Changelog file for more details.

Remember that iptables >= 1.4.3 starts enforcing the deprecation of NAT
filtering that was added in 1.4.2-rc1, filtering rules in the NAT tables
will cause an error instead of a warning from now on. Please make sure
your rulesets are update appropriately.

Version 1.4.3.2 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers


--------------090700010709050000090606
Content-Type: text/plain;
 name="changes-iptables-1.4.3.2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.3.2.txt"

Jan Engelhardt (12):
      libxt_tcpmss: fix an inversion while parsing --mss
      iptables-multi: support "iptables-static" as a callable name
      libxtables: reorder .version member
      build: do not run ldconfig for DESTDIR installations
      build: add configure option to disable ip6tables
      build: add configure option to disable ipv4 iptables
      libxtables: provide IPv6 zero address variable
      iptables: print negation extrapositioned
      Merge commit 'v1.4.3'
      Merge branch 'plus'
      CLASSIFY: document non-standard interpretation behavior
      libxt_conntrack: properly output negation symbol

Pablo Neira Ayuso (1):
      build: bump version to 1.4.3.2


--------------090700010709050000090606--
