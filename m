From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6:export nd_tbl
Date: Tue, 06 Dec 2011 12:57:43 -0500 (EST)
Message-ID: <20111206.125743.160144181036493070.davem@davemloft.net>
References: <a46bd31bb9a4876e97f96e82d399a26506646d04.1323154266.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a46bd31bb9a4876e97f96e82d399a26506646d04.1323154266.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weiping Pan <panweiping3@gmail.com>
Date: Tue,  6 Dec 2011 14:52:41 +0800

> A customer wants to use nd_tbl in his kernel module,
> the easiest way is to export nd_tbl, just as arp_tbl.
> 
> There were some requests to export nd_tbl, like:
> http://marc.info/?l=netfilter-devel&m=111416950824614&w=2
> http://marc.info/?l=linux-netdev&m=110715893206991&w=2
> 
> But they were all rejected.
> I want to know the reason why can't nd_tbl be exported just as arp_tbl,
> and how can we look up nd_tbl without exporting it.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

We do not accomodate out-of-tree code, arp_tbl is exported because
modules (such as ATM clip) in the upstream tree use that symbol.
