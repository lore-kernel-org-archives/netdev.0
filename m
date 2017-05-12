From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit
 into dump buffer.
Date: Fri, 12 May 2017 11:24:47 -0400 (EDT)
Message-ID: <20170512.112447.1421545301592945998.davem@davemloft.net>
References: <20170512111510.2697-1-mq@ucw.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: mq@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512111510.2697-1-mq@ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Moskyto Matejka <mq@ucw.cz>
Date: Fri, 12 May 2017 13:15:10 +0200

> -int rt6_dump_route(struct rt6_info *rt, void *p_arg);
> +int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);

Please use "bool" and "true"/"false" for boolean values.

What does ipv4 do in this situation?

I'm hesitant to be OK with adding a new nlmsg flag just for this case
if we solve this problem differently and using existing mechanisms
elsewhere.
