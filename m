From: Abhijit Menon-Sen <ams@wiw.org>
Subject: Re: CONFIG_NET_FASTROUTE in 8390
Date: Thu, 17 Jun 2004 20:49:24 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617204924.H5207@lustre.dyn.wiw.org>
References: <20040617141626.60307.qmail@web90108.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pragati Dhingra <pragatidhingra@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20040617141626.60307.qmail@web90108.mail.scd.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 2004-06-17 07:16:26 -0700, pragatidhingra@yahoo.com wrote:
>
> struct rtable does not have a member named key and I could not locate
> a #define which would define "key". 

In 2.4 kernels, rtable does have a "struct rt_key" member named key, and
the code you're reading (I couldn't find the e8390_fast_route function)
is probably for 2.4.

In 2.6 kernel, the rt_key has been replaced by a "struct flowi *".
(See include/net/route.h and ip_route_output_key.)

-- ams
