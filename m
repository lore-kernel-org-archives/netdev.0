From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: silence errors about kernel missing 6rd on "ip tun
 show".
Date: Wed, 31 Mar 2010 16:06:42 -0700
Message-ID: <20100331160642.75766629@s6510>
References: <20100331080854.GA3810@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Cassen <acassen@freebox.fr>, 575970@bugs.debian.org,
	netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56373 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553Ab0CaXGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 19:06:49 -0400
In-Reply-To: <20100331080854.GA3810@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Mar 2010 10:08:54 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> Hello!
> 
> As reported in http://bugs.debian.org/575970 there is currently a warning
> printed for every tunnel when using latest iproute2 on atleast <= 2.6.32
> kernels (missing 6rd?!).
> 
> The attached patch avoids perror when errno is EINVAL, which I assume
> is the way to detect missing 6rd support. A better/cleaner
> method to detect and avoid 6rd when there's no kernel support
> is more then welcome.
> 
> Regards,
> Andreas Henriksson
> 

I will wait (a little while) to see if Alexandre has a preferred alternative.
