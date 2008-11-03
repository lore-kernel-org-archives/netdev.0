From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Mon, 3 Nov 2008 14:49:23 -0800
Message-ID: <20081103144923.244158f3@extreme>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081102.002736.193701976.davem@davemloft.net>
	<649aecc70811031419o78e9046eu52adf78eef8da7d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Rick Jones" <rick.jones2@hp.com>, rhee@eos.ncsu.edu,
	netdev@vger.kernel.org
To: "Sangtae Ha" <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45153 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800AbYKCWt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:49:28 -0500
In-Reply-To: <649aecc70811031419o78e9046eu52adf78eef8da7d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Nov 2008 17:19:52 -0500
"Sangtae Ha" <sangtae.ha@gmail.com> wrote:

> Hi all,
> 
> We had rather extensive testings with one MacOSX receiver of the
> latest Leopard release.
> As we had one macbook pro available in the lab, all the testing
> results are with the one receiver.
> Based on the tested results, MacOSX also doesn't break the algorithm.
> 
> Please see the results at the following:
> 
> http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing#Testing_with_MacOSX
> 
> One thing I observed with FreeBSD and MacOS receivers is that
> even though we set the large send and recv buffer and run the iperf
> with the large fixed memory,
> without manually setting the window scale parameter to a higher value,
> the receiver window is limited to 64K << 3 (which is the default of MacOSX).
> 
> Because of that, I had to set the window scailing parameter from 3 to
> 13 manually.
> This also affects SACK not triggering with the default window scale factor of 3.
> Linux certainly doesn't have this problem.
> 
> Probably, MacOSX and FreeBSD may need some updates for this issue.
> 
> Thank you for all your feedbacks,
> 
> Sangtae

Thanks for the pro-active testing.
