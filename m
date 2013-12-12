From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 12:24:03 -0500 (EST)
Message-ID: <20131212.122403.548901877993258405.davem@davemloft.net>
References: <20131211192138.GB4675@order.stressinduktion.org>
	<20131211.155452.558417595732985707.davem@davemloft.net>
	<52A99DD0.9030007@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A99DD0.9030007@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Thu, 12 Dec 2013 12:28:16 +0100

> Admins want to know why ipv6 autoconf didn't work, not so much
> how many times it didn't work. This requires a text message.

Again, they don't get this for ARP, or any other similar event.  Why
is ipv6 autoconf so damn special that it demands unique treatment?

I do not want each subsystem to decide their own custom way to
notify people that some interesting event happened.  That's the
worst possible user experience.
