From: Jon Mason <mason@myri.com>
Subject: Re: [PATCH 3/9] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 15:26:53 -0500
Message-ID: <BANLkTimdYLkcPpWFkC8f3vfbL3xoyi+FXQ@mail.gmail.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-3-git-send-email-mason@myri.com>
	<1309188438.2744.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33029 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab1F0U3Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 16:29:25 -0400
Received: by iyb12 with SMTP id 12so4371369iyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 13:29:24 -0700 (PDT)
In-Reply-To: <1309188438.2744.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 10:27 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Mon, 2011-06-27 at 10:05 -0500, Jon Mason wrote:
>> Clean up watchdog reset code:
>> =A0- move code that checks for stuck slice to a common routine
>> =A0- unless there is a confirmed h/w fault, verify that a stuck
>> =A0 =A0slice is still stuck in the watchdog worker; if the slice is =
no
>> =A0 =A0longer stuck, abort the reset.
>> =A0- this removes an egregarious 2000ms pause in the watchdog worker=
 that
> [...]
>
> Egregious & gregarious? =A0Or maybe just egregious?

It's my new errno, -EGREGARIOUS.  :)

Thanks, I'll roll this and Joe's comments in version #2.

>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
