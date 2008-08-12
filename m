From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Tue, 12 Aug 2008 01:18:22 -0700 (PDT)
Message-ID: <20080812.011822.155249871.davem@davemloft.net>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, billfink@mindspring.com,
	fragabr@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: thomas.jarosch@intra2net.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200808120946.19459.thomas.jarosch@intra2net.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Date: Tue, 12 Aug 2008 09:46:17 +0200

> David, I agree with you, though I'm not sure about the end user experience:

We had the same situation with ECN and window scaling, and my proposal
is the same as how we handled those situations involving broken
middleware boxes.
