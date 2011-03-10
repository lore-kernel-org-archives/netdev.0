From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Thu, 10 Mar 2011 02:17:51 -0500
Message-ID: <20110310021751.2f5fb8bc.billfink@mindspring.com>
References: <20110310002458.5a94f563.billfink@mindspring.com>
	<2049243270.17294.1299737824096.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Injong Rhee <rhee@ncsu.edu>, David Miller <davem@davemloft.net>,
	xiyou wangcong <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org, sangtae ha <sangtae.ha@gmail.com>,
	Lucas Nussbaum <lucas.nussbaum@loria.fr>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:56443 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750944Ab1CJHR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 02:17:57 -0500
In-Reply-To: <2049243270.17294.1299737824096.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Mar 2011, Stephen Hemminger wrote:

> Bill what is the HZ in your kernel config.
> I am concerned hystart doesn't work well with HZ=100

HZ=1000

But I did have tcp_timestamps disabled.  Should I re-run
the tests with tcp_timestamps enabled?

					-Bill
