From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add information about COLORFGBG to ip.8 man
 page
Date: Wed, 20 Sep 2017 17:56:33 -0700
Message-ID: <20170920175633.55ee67c9@xeon-e3>
References: <873bbae3-db89-b572-748b-cfa62922f883@ica.jku.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roland Hopferwieser <rhopfer@ica.jku.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:51813 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdIUA4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:56:36 -0400
Received: by mail-pf0-f180.google.com with SMTP id b70so2386344pfl.8
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 17:56:36 -0700 (PDT)
In-Reply-To: <873bbae3-db89-b572-748b-cfa62922f883@ica.jku.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Sep 2017 22:04:16 +0200
Roland Hopferwieser <rhopfer@ica.jku.at> wrote:

> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index ae018fdf..2a27a56e 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -187,7 +187,8 @@ executes specified command over all objects, it 
> depends if command supports this
> 
>   .TP
>   .BR "\-c" , " -color"
> -Use color output.
> +Use color output. The color palette is affected by the COLORFGBG 
> environment variable, which typically has the form "fg;bg".
> +If "bg" is set to 0-6 or 8, the dark color palette is used.
> 
>   .TP
>   .BR "\-t" , " \-timestamp"

Your patch was damaged by the mailer you used.
Please fix and resubmit.

$ patch -p1 < ~/Downloads/iproute2-Add-information-about-COLORFGBG-to-ip.8-man-page.patch 
patching file man/man8/ip.8
patch: **** malformed patch at line 23: depends if command supports this
