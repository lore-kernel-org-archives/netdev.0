From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Mon, 04 May 2009 14:36:30 +0400
Message-ID: <49FEC52E.6070501@msgid.tls.msk.ru>
References: <1241433136.6126.70.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:53338 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbZEDKgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 06:36:31 -0400
In-Reply-To: <1241433136.6126.70.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> This patch adds three attribute files in /sys/class/net/$dev/ for tun
> devices; allowing userspace to obtain the information which TUNGETIFF
> offers, and more, but without having to attach to the device in question
> (which may not be possible if it's in use).
> 
[]
> +static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
> +static DEVICE_ATTR(owner, 0444, tun_show_owner, NULL);
> +static DEVICE_ATTR(group, 0444, tun_show_group, NULL);

Is there any reason why those files are not writable?

I understand flags one, sorta (but it is still useful to
be able to change some flags, like persistent, while it's
running), but for owner/group - it's just an integer that's
used to check permissions for ioctl, and can be set in sysfs
just fine.  I think anyway.

/mjt
