From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RESEND 0/2] enable hires timer to timeout datagram socket
Date: Fri, 18 Aug 2017 22:18:54 +0200
Message-ID: <20170818201854.xes246oviptinwvq@localhost>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, eduval@amazon.com,
        anchalag@amazon.com, tglx@linutronix.de
To: Vallish Vaidyeshwara <vallish@amazon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503081850-10671-1-git-send-email-vallish@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 06:44:08PM +0000, Vallish Vaidyeshwara wrote:
> There has been a behavior change in 4.9 kernel with refactoring of Kernel
> timer wheel in 4.8. We have a use case wherein our datagram socket
> application is sensitive to socket timeout including long timeouts.
> 
> One of the test runs with a timeout value of 180 seconds timed out at
> 190 seconds.

So the whole premise of the new timer wheel is that long timeouts need
not be very accurate.

> Patch 1: Has core code change of enabling hires timer to timeout datagram
> 	 socket on AF_UNIX and AF_INET domain

Using hrtimers will hurt performance for most applications.  Can you
please explain your use case and why is it so important?

Thanks,
Richard
