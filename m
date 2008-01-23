From: David Miller <davem@davemloft.net>
Subject: Re: Assertions in latest kernels
Date: Tue, 22 Jan 2008 23:57:23 -0800 (PST)
Message-ID: <20080122.235723.52174015.davem@davemloft.net>
References: <OFBE734C49.5B16C8E9-ON652573D9.002548B8-652573D9.0026407B@in.ibm.com>
	<OFC47DE839.9B2F85A5-ON652573D9.002BA994-652573D9.002B38BA@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752841AbYAWH5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:57:15 -0500
In-Reply-To: <OFC47DE839.9B2F85A5-ON652573D9.002BA994-652573D9.002B38BA@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 23 Jan 2008 13:22:05 +0530

> Sorry for the duplicate bug report, I just saw that Dave Young had already
> reported three of the
> 4 assertions that I was getting. The only different assert I am getting is:
> 
> iperf with multiple threads almost always gets these 4, *especially* when I
> do some batching :).
> 
> static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
> {
>       ...
>       if (WARN_ON(!tp->sacked_out && tp->fackets_out))
>             tp->fackets_out = 0;
>       ...
> }

Does this assertion show up first or do you get the other TCP
ones first?  It might be important, in that if you get the
others ones first that corrupted state might be what leads to
this one.

