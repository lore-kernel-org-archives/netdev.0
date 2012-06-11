From: scott@scottnz.com
Subject: Re: [PATCH rfc net] Allow the autoconfigured network interface to be
 renamed.
Date: Mon, 11 Jun 2012 22:44:34 +1200
Message-ID: <db9468c7722be0c4131ad015bdae2e31.squirrel@scottnz.com>
References: <1339228087-14870-1-git-send-email-scott@scottnz.com>
    <20120610.202515.138701034400919651.davem@davemloft.net>
    <f8f3fa05ddbe3a2e1613588754f151ac.squirrel@scottnz.com>
    <20120611.031053.1433253186495303724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: scott@scottnz.com, netdev@vger.kernel.org,
	scott.parlane@alliedtelesis.co.nz
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edgewireless.tk ([184.82.109.251]:36624 "EHLO vps1.scottnz.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751854Ab2FKKpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 06:45:04 -0400
In-Reply-To: <20120611.031053.1433253186495303724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: scott@scottnz.com
> Date: Mon, 11 Jun 2012 21:58:45 +1200
>
>> They use nfsroot which prevents udev rules from working correctly
>> (because you cant take down the interface to rename it)
>
> This is why I hate nfsroot as implemented in the kernel.
>
The same is true for root over nfs as configured by the initramfs,
conviently there is a small window where you can interfere with it
(at the initramfs stage), or I should say there-was,
its not available anymore, specifically because glibc dropped the sunrpc
code. (This is probably an artifact of gentoo's initramfs more than anything,
but it was the last distro that I could find to network boot without fully
RYO)

> Do this right and use an initial ramdisk, then you won't have
> this huge disconnect between different device names due to
> lack of udev.
>
> Thanks, you've confirmed that this patch is totally inappropriate.
So be it, we will continue to run it, because its the simpliest way to
get what we want done (and most of our software developers can deal
with kernel code, more so than libc)

Regards,
Scott
