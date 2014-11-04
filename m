From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipv4: ip_frag_queue function clean-up
Date: Tue, 04 Nov 2014 15:12:10 -0500 (EST)
Message-ID: <20141104.151210.1901212031045734478.davem@davemloft.net>
References: <1415130097-14490-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415130097-14490-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  4 Nov 2014 20:41:37 +0100

> -remove unnecessary else after break
> -declare free_it sk_buff * only once (like prev and next)
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

I disagree.

Declaring a local variable in it's inner-most scope is preferable
to moving it to the top level and making the job of the compiler
and the code auditor more difficult.

I'm not applying this, sorry.
