From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Mon, 11 Jul 2016 16:13:11 +1000
Message-ID: <20160711161311.5049ec64@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>,
	Dinan Gunawardena <dinan.gunawardena@netronome.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:33385 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757551AbcGKGNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 02:13:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) produced this warning (CONFIG_MPLS is disabled):

net/ipv4/tunnel4.c: In function 'tunnel4_init':
net/ipv4/tunnel4.c:223:1: warning: label 'err_mpls' defined but not used [-Wunused-label]
 err_mpls:
 ^

and the powerpc ppc64_defconfig build produced this (CONFIG_IPV6 is disabled):

net/ipv4/tunnel4.c: In function 'tunnel4_init':
net/ipv4/tunnel4.c:226:1: warning: label 'err_ipv6' defined but not used [-Wunused-label]
 err_ipv6:
 ^

Introduced by commit

  8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")

-- 
Cheers,
Stephen Rothwell
