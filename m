From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Mon, 05 May 2014 23:12:29 -0400 (EDT)
Message-ID: <20140505.231229.136734008603421707.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-9-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:57 -0700

> This is all the code that saves connection information
> between different sockets. Not really essential for
> small systems.

It is absolutely essential unless you want poor performance
of TCP connections.

I'm not applying this.
