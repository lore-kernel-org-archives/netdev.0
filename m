From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: Add unix_diag.h to kernel userspace headers
Date: Sat, 21 Jan 2012 22:13:23 +0400
Message-ID: <4F1B0043.1000304@parallels.com>
References: <20120120124109.478f65e3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1670 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab2AUSNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jan 2012 13:13:32 -0500
In-Reply-To: <20120120124109.478f65e3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2012 12:41 AM, Stephen Hemminger wrote:
> The change to use provide unix domain diag information in iproute2 means that
> an additional header file has to be added to the kbuild header export list.
> This ensures that any changes to the header file get picked up in future merges.

It should be already there since 6a1c9522 (unix_diag: Include unix_diag.h into header-y target)

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Patch for -net (ie 3.3) 
> 
> --- a/include/linux/Kbuild	2012-01-10 10:56:59.659188065 -0800
> +++ b/include/linux/Kbuild	2012-01-20 12:36:53.518655336 -0800
> @@ -375,6 +375,7 @@ header-y += uio.h
>  header-y += ultrasound.h
>  header-y += un.h
>  header-y += unistd.h
> +header-y += unix_diag.h
>  header-y += usbdevice_fs.h
>  header-y += utime.h
>  header-y += utsname.h
> 
