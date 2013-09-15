From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: add the PTP_SYS_OFFSET ioctl to the testptp program
 clock
Date: Sun, 15 Sep 2013 10:48:12 +0200
Message-ID: <20130915084811.GA10163@netboy>
References: <20130914080306.GC23682@zhudong.nay.redhat.com>
 <20130914143144.GA4206@netboy>
 <20130914153952.GD23682@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:37519 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab3IOIs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 04:48:26 -0400
Content-Disposition: inline
In-Reply-To: <20130914153952.GD23682@zhudong.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 14, 2013 at 11:39:52PM +0800, Dong Zhu wrote:
> On Sat, Sep 14, 2013 at 04:31:46PM +0200, Richard Cochran wrote:
> > On Sat, Sep 14, 2013 at 04:03:06PM +0800, Dong Zhu wrote:
> > > This patch add a method into testptp.c to measure the time offset
> > > between phc and system clock through the ioctl PTP_SYS_OFFSET.
> > > 
> > 
> > This is a nice addition to the testptp program. I do have a few
> > comments, below.
> > 
> 
> Thanks very much for your comments, I have modified the patch as below,
> Cuold you have a look at it again ? Any comments would be appreciated.

It looks better, but could you please tweak a few more things?

> Subject: Re: [PATCH] ptp: add the PTP_SYS_OFFSET ioctl to the testptp program clock

The subject line has the word "clock" at the end by mistake.
 
...

> diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
> index f59ded0..8acdc70 100644
> --- a/Documentation/ptp/testptp.c
> +++ b/Documentation/ptp/testptp.c
> @@ -112,6 +112,8 @@ static void usage(char *progname)
>  		" -f val     adjust the ptp clock frequency by 'val' ppb\n"
>  		" -g         get the ptp clock time\n"
>  		" -h         prints this message\n"
> +		" -k val     measure the time offset between phc and system clock "
> +		"for 'val' times (Maximum 25)\n"

This line is getting a bit too long for the terminal. Please line up
the text, like this:

		" -k val     measure the time offset between phc and system clock\n"
		"            for 'val' times (Maximum 25)\n"

Also, when you resubmit the patch, add "net-next" and a patch version,
like this: [PATCH net-next v3].

Thanks,
Richard
