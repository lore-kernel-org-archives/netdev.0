From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv6: fib: don't sleep inside atomic lock
Date: Fri, 22 Aug 2014 10:55:37 -0700 (PDT)
Message-ID: <20140822.105537.779696105209269317.davem@davemloft.net>
References: <20140821143103.GA25021@kalium.Speedport_W723_V_Typ_A_1_01_001>
	<1408642668-5808-1-git-send-email-bebl@mageta.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@redhat.com
To: bebl@mageta.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408642668-5808-1-git-send-email-bebl@mageta.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Block <bebl@mageta.org>
Date: Thu, 21 Aug 2014 19:37:48 +0200

> The function fib6_commit_metrics() allocates a piece of memory in mode
> GFP_KERNEL while holding an atomic lock from higher up in the stack, in
> the function __ip6_ins_rt(). This produces the following BUG:
 ...
> Fixing this by replacing the mode GFP_KERNEL with GFP_ATOMIC.
> 
> Signed-off-by: Benjamin Block <bebl@mageta.org>

Applied, thanks.
