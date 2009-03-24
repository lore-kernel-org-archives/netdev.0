From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE]: Release of iptables-1.4.3.1
Date: Tue, 24 Mar 2009 14:08:11 +0100
Message-ID: <49C8DB3B.909@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010306040001040504080508"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010306040001040504080508
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

     iptables version 1.4.3.1

the iptables release for the 2.6.29 kernel. This version includes a
compilation fix and a couple of minor fixes:

- compilation error fix from Peter Volkov

- documentation update from Jan Engelhardt

- cleanup error reporting by myself.

Check out the Changelog for more details.

Remember that this release (and 1.4.3) starts enforcing the deprecation
of NAT filtering that was added in 1.4.2-rc1, filtering rules in the NAT
tables will cause an error instead of a warning from now on. Please make
sure your rulesets are update appropriately.

Version 1.4.3.1 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers

--------------010306040001040504080508
Content-Type: text/plain;
 name="changes-iptables-1.4.3.1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.3.1.txt"

Jan Engelhardt (2):
      iptables-save: minor corrections to the manpage markup
      libxt_hashlimit: add missing space for iptables-save output

Pablo Neira Ayuso (2):
      build: bump version to 1.4.3.1
      iptables: refer to dmesg if we hit EINVAL

Peter Volkov (2):
      libxtables: fix compile error due to incomplete change
      build: fix linker issue when LDFLAGS contains --as-needed


--------------010306040001040504080508--
