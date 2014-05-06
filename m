From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 10:03:24 -0700
Message-ID: <1399395804.15399.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	 <20140505.231229.136734008603421707.davem@davemloft.net>
	 <20140506032114.GP2382@two.firstfloor.org>
	 <20140505.232327.578134514220748085.davem@davemloft.net>
	 <20140506155703.GA20391@cloud>
	 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140506164546.GB20536@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506164546.GB20536@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-06 at 09:45 -0700, josh@joshtriplett.org wrote:

> Sounds like we have some optimization to do, then; there's no
> fundamental unfixable reason for that delta.

I think you have little idea of the reasons for this delta.

Some servers handle 10 millions of TCP flows, using as little as 1KB per
connection in user space, all included.

Do you have an idea of how much memory is needed for 10 millions TCP
sockets in the kernel ?
