From: Rusty Russell <rusty@rustcorp.com.au>
Subject: TODO list before feature freeze
Date: Thu, 18 Jul 2002 19:34:53 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020718093928.18BC942CD@lists.samba.org>
Cc: netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi all,

	With four months to go before the feature freeze, it's
important to compile a feature list for netfilter-related things.  I
see the following coming up:

Connection tracking:
	o TCP window tracking finally goes in.
	o Fix the extremely low TCP RST timeout
	o Fix the UDP timeout calculations to be per-port.
	o Improve hashing
	o Fix the massive timer performance problem.
	o Zero-copy-safe the connection tracking framework
	o ctnetlink support

iptables:
	o Change over to a netlink interface
		o Back to add/delete/replace interface + commit.
	o Rewrite libiptc to use netlink (to port iptables).
	o Write new ip extension for iptables.
	o Zero-copy-safe the iptables framework

NAT:
	o Zero-copy-safe the NAT framework

Please add feature requests: note that I have not been following the
lists, so "obvious" things may not be obvious to me.

Thanks for your patience,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
