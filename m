From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Introduce the use of the managed version of
 kzalloc
Date: Sun, 18 May 2014 20:56:55 -0400 (EDT)
Message-ID: <20140518.205655.2295290164768048817.davem@davemloft.net>
References: <20140516180725.GA12976@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140516180725.GA12976@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 16 May 2014 23:37:25 +0530

> Not compile tested due to incompatible architecture.

Please add an explicit linux/device.h include to make absolutely
sure the devm_*() are available.
