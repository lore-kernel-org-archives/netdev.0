From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Fri, 08 Jun 2012 18:04:55 +0200
Message-ID: <1339171495.6001.118.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
	 <1339104606.6001.4.camel@edumazet-glaptop>
	 <20120607223752.GA4475@electric-eye.fr.zoreil.com>
	 <1339134438.6001.13.camel@edumazet-glaptop>
	 <20120608154106.GD5024@kvack.org>
	 <67d8beaf421874815145fdefc69b3366@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Francois Romieu <romieu@fr.zoreil.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <67d8beaf421874815145fdefc69b3366@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-08 at 18:56 +0300, Denys Fedoryshchenko wrote:

> Right now i am routing around 700Mbps over there, and noticed some 
> problem with pskb_expand_head,
> but that's separate question i will ask, if i will not be able to sort 
> it out by myself.
> 

Before spending too much time on this, make sure you use a kernel
including commit 617c8c11236 ( skb: avoid unnecessary reallocations in
__skb_cow )
