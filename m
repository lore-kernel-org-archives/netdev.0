From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] ptp: Fix compiler warnings in the testptp
 utility
Date: Tue, 25 Mar 2014 12:45:23 +0100
Message-ID: <20140325114523.GB14836@netboy>
References: <1395746646-28299-1-git-send-email-christian.riesch@omicron.at>
 <a2330f7d-0abf-4ee0-9288-1e881b2b5368@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dong Zhu <bluezhudong@gmail.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:62938 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaCYLp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 07:45:28 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so336434eek.31
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 04:45:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a2330f7d-0abf-4ee0-9288-1e881b2b5368@mary.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 12:24:06PM +0100, Christian Riesch wrote:
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: Dong Zhu <bluezhudong@gmail.com>
> ---
>  Documentation/ptp/testptp.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
> index 13bddd5..14bf19e 100644
> --- a/Documentation/ptp/testptp.c
> +++ b/Documentation/ptp/testptp.c
> @@ -496,14 +496,14 @@ int main(int argc, char *argv[])
>  			interval = t2 - t1;
>  			offset = (t2 + t1) / 2 - tp;
>  
> -			printf("system time: %ld.%ld\n",
> +			printf("system time: %lld.%u\n",
>  				(pct+2*i)->sec, (pct+2*i)->nsec);
> -			printf("phc    time: %ld.%ld\n",
> +			printf("phc    time: %lld.%u\n",
>  				(pct+2*i+1)->sec, (pct+2*i+1)->nsec);
> -			printf("system time: %ld.%ld\n",
> +			printf("system time: %lld.%u\n",
>  				(pct+2*i+2)->sec, (pct+2*i+2)->nsec);
> -			printf("system/phc clock time offset is %ld ns\n"
> -				"system     clock time delay  is %ld ns\n",

Use PRId64 instead?

Thanks,
Richard

> +			printf("system/phc clock time offset is %lld ns\n"
> +				"system     clock time delay  is %lld ns\n",
>  				offset, interval);
>  		}
>  
> -- 
> 1.7.9.5
> 
