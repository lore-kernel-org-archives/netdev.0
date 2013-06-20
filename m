From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [PATCH v2] tcp: Fixed MD5 key lookups when
 adding/removing MD5.
Date: Wed, 19 Jun 2013 21:22:42 -0700 (PDT)
Message-ID: <20130619.212242.503302312923618047.davem@davemloft.net>
References: <1371209403-28275-1-git-send-email-aydin.arik@alliedtelesis.co.nz>
	<1371214687.3252.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aydin.arik@alliedtelesis.co.nz, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371214687.3252.130.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Jun 2013 05:58:07 -0700

> On Fri, 2013-06-14 at 23:30 +1200, Aydin Arik wrote:
>> MD5 key lookups on a given TCP socket were being performed
>> incorrectly. This fix alters parameter inputs to the MD5
>> lookup function tcp_md5_do_lookup, which is called by functions
>> tcp_md5_do_add and tcp_md5_do_del. Specifically, the change now
>> inputs the correct address and address family required to make
>> a proper lookup.
>> 
>> Commit a915da9b69273815527ccb3789421cb7027b545b ("tcp: md5: rcu conversion")
>> is the source of the regression.
>> 
>> Signed-off-by: Aydin Arik <aydin.arik@alliedtelesis.co.nz>

Applied, thanks.
