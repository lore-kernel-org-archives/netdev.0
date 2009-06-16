From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.4
Date: Tue, 16 Jun 2009 13:54:03 +0200
Message-ID: <4A3787DB.1040704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040303070709050308040806"
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040303070709050308040806
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

     iptables version 1.4.4

the iptables release for the 2.6.30 kernel. Changes include:

- support for the new features in the 2.6.30 kernel, namely the
   cluster match and persistent multi-range NAT mappings

- support for the ipset set match and target

- various minor fixes and cleanups

- documentation updates

Version 1.4.4 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

--------------040303070709050308040806
Content-Type: text/plain;
 name="changes-iptables-1.4.4.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.4.txt"

Frank Tobin (1):
      libxt_tcp: fix a manpage syntax typo

Ian Bruce (1):
      libxt_tcp: manpage corrections and suggestions

Jan Engelhardt (15):
      Add new COMMIT_NOTES document
      xtables: use extern "C"
      extensions: add const qualifiers in print/save functions
      iptables: replace open-coded sizeof by ARRAY_SIZE
      addrtype: fix one manpage type
      manpages: do not include v4-only modules in ip6tables manpage
      libip6t_policy: remove redundant functions
      policy: use direct xt_policy_info instead of ipt/ip6t
      policy: merge ipv6 and ipv4 variant
      build: fix manpage collection
      extensions: use NFPROTO_UNSPEC for .family field
      DNAT/SNAT: add manpage documentation for --persistent flag
      extensions: remove redundant casts
      iptables: close open file descriptors
      manpages: markup corrections

Jozsef Kadlecsik (1):
      Updated set/SET match and target to support multiple ipset protocols.

Pablo Neira Ayuso (2):
      extensions: add `cluster' match support
      xtables: fix segfault if incorrect protocol name is used

Patrick McHardy (2):
      SNAT/DNAT: add support for persistent multi-range NAT mappings
      Merge branch 'stable' of git://dev.medozas.de/iptables

kd6lvw (1):
      libxt_connlimit: initialize v6_mask


--------------040303070709050308040806--
