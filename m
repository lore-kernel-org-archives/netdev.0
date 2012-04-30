From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 13:41:40 -0400 (EDT)
Message-ID: <20120430.134140.1738751315208907289.davem@davemloft.net>
References: <1335760199.20866.33.camel@pasglop>
	<4F9E188E.80503@googlemail.com>
	<1335763568.20866.37.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: benh@kernel.crashing.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335763568.20866.37.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 30 Apr 2012 15:26:08 +1000

> David, what's the right way to fix that ?

There is no doubt that sock_fprog is the correct datastructure to use.
