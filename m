From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: Allow selecting trigger/event index in testptp
Date: Mon, 3 Feb 2014 16:59:10 +0100
Message-ID: <20140203155909.GA6011@netboy>
References: <1391438187-21834-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:38927 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaBCP7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 10:59:22 -0500
Received: by mail-ee0-f53.google.com with SMTP id t10so3755301eei.40
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 07:59:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391438187-21834-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 03, 2014 at 03:36:27PM +0100, Stefan S=F8rensen wrote:
> Currently the trigger/event is hardcoded to 0, this patch adds
> a new command line argument -i to select an arbitrary trigger/
> event.

This is a nice extension of the program, but ...

> diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.=
c
> index a74d0a8..04b21cd 100644
> --- a/Documentation/ptp/testptp.c
> +++ b/Documentation/ptp/testptp.c
> @@ -123,7 +123,8 @@ static void usage(char *progname)
>  		" -P val     enable or disable (val=3D1|0) the system clock PPS\n"
>  		" -s         set the ptp clock time from the system time\n"
>  		" -S         set the system time from the ptp clock time\n"
> -		" -t val     shift the ptp clock time by 'val' seconds\n",
> +		" -t val     shift the ptp clock time by 'val' seconds\n"
> +		" -i val     index for event/trigger\n",

can we please keep the options in alphabetical order?

Thanks,
Richard
