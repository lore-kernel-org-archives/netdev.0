From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 3/7 RFC] TCPCT part 1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 21 Nov 2009 23:40:08 -0500
Message-ID: <4B08C0A8.6070302@gmail.com>
References: <4B06A8CF.3000303@gmail.com>	<20091120.092408.208010931.davem@davemloft.net>	<4B081A81.5000602@gmail.com> <20091121.111844.54272535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:63932 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbZKVEkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 23:40:07 -0500
Received: by yxe17 with SMTP id 17so3939513yxe.33
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 20:40:12 -0800 (PST)
In-Reply-To: <20091121.111844.54272535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Sat, 21 Nov 2009 11:51:13 -0500
> 
>> This code was based on net/ipv4/tcp_minisocks.c for syncookies.
>> Apparently, default for syncookies has been controversial.
> 
> I'll have to change that, it doesn't make any sense.  Thanks
> for pointing it out.
> 
Once again, for the umpteenth time, I learn that existing code
proves to be a bad example to follow....


>> Would you accept always default to TCP_COOKIE_MAX?
> 
> Sure, let's see what breaks.
> 
Unlikely to break anything, according to studies of the subject:

         Medina, A., Allman, M., and Floyd, S., "Measuring Interactions
         Between Transport Protocols and Middleboxes", Proceedings 4th
         ACM SIGCOMM/USENIX Conference on Internet Measurement, October
         2004.  http://www.icsi.berkeley.edu/pubs/networking/tbit-
         Aug2004.pdf

TCPCT part 2 is much more likely to break things....

