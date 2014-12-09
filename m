From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Tue, 09 Dec 2014 14:54:47 -0500 (EST)
Message-ID: <20141209.145447.2234157264287438778.davem@davemloft.net>
References: <547C82A6.2030808@users.sourceforge.net>
	<547CA157.1080401@cogentembedded.com>
	<5480DA32.8000201@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5480DA32.8000201@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 04 Dec 2014 23:03:30 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 4 Dec 2014 22:50:28 +0100
> 
> Further update suggestions were taken into account before and after a patch
> was applied from static source code analysis.

Generally speaking, it is advisable to not leave error pointers in data
structures, even if they are about to be free'd up in an error path
anyways.

Therefore I do not like some of the patches in this series.

Sorry.
