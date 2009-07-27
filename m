From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/12] net/netlabel: Correct redundant test
Date: Mon, 27 Jul 2009 11:36:21 -0700 (PDT)
Message-ID: <20090727.113621.207329776.davem@davemloft.net>
References: <Pine.LNX.4.64.0907271815260.2682@ask.diku.dk>
	<200907271337.30401.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754164AbZG0SgR@vger.kernel.org>
In-Reply-To: <200907271337.30401.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 27 Jul 2009 13:37:29 -0400

> On Monday 27 July 2009 12:15:43 pm Julia Lawall wrote:
>> From: Julia Lawall <julia@diku.dk>
>>
>> entry was tested for NULL near the beginning of the function, followed by a
>> return, and there is no intervening modification of its value.
>>
>> A simplified version of the semantic match that finds this problem is as
>> follows: (http://www.emn.fr/x-info/coccinelle/)
 ...
>> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> Good catch, thanks.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied to net-next-2.6
