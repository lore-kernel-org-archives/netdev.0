From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 10/18]  net/g96100eth: replace 	gt96100_delay() with msleep_interruptible()
Date: Sun, 31 Oct 2004 06:06:23 -0500
Message-ID: <4184C72F.8000905@pobox.com>
References: <E1CO1vu-0002Lf-5c@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1vu-0002Lf-5c@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> @@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
>  	// wait for abort to complete
>  	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
>  		// snooze for 20 msec and check again
> -		gt96100_delay(1);
> +		msleep_interruptible(20);
>  	
>  		if (--timedout == 0) {


don't change the behavior of the driver, even if it disagrees with the 
comment.
