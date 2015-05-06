From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH 1/4] ip: document exit code
Date: Wed, 6 May 2015 20:16:25 +0300
Message-ID: <20150506171625.GA849@angus-think.lan>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
 <1430931483-28595-2-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34607 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbEFRQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 13:16:56 -0400
Received: by wgso17 with SMTP id o17so18989722wgs.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 10:16:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430931483-28595-2-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, May 06, 2015 at 09:58:00AM -0700, Stephen Hemminger wrote:
> From: Stephen Hemminger <shemming@brocade.com>
> 
> The ip command has always had a consistent exit status
> document it so that developers see it.
> ---
>  man/man8/ip.8 | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index 43ddac9..9574a50 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -275,6 +275,10 @@ Usually it is
>  or, if the objects of this class cannot be listed,
>  .BR "help" .
>  
> +.SH EXIT STATUS
> +Exit statsis is 0 if command was sucessful, and 1 if there is a syntax error.
statsis -> status ?                 sucessful -> successful ?

> +If an error was reported by the kernel exit status is 2.
> +
>  .SH HISTORY
>  .B ip
>  was written by Alexey N. Kuznetsov and added in Linux 2.2.
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
