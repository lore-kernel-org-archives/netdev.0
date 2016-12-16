From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Fri, 16 Dec 2016 23:05:30 +0100
Message-ID: <20161216220530.GA25258@netboy>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Henrik Austad <haustad@cisco.com>,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: henrik@austad.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33040 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756119AbcLPWFf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 17:05:35 -0500
Content-Disposition: inline
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 06:59:04PM +0100, henrik@austad.us wrote:
> The driver is directed via ConfigFS as we need userspace to handle
> stream-reservation (MSRP), discovery and enumeration (IEEE 1722.1) and
> whatever other management is needed.

I complained about configfs before, but you didn't listen.

> 2 new fields in netdev_ops have been introduced, and the Intel
> igb-driver has been updated (as this an AVB-capable NIC which is
> available as a PCI-e card).

The igb hacks show that you are on the wrong track.  We can and should
be able to support TSN without resorting to driver specific hacks and
module parameters.

> Before reading on - this is not even beta, but I'd really appreciate if
> people would comment on the overall architecture and perhaps provide
> some pointers to where I should improve/fix/update

As I said before about V1, this architecture stinks.  You appear to
have continued hacking along and posted the same design again.  Did
you even address any of the points I raised back then?

You are trying to put tons of code into the kernel that really belongs
in user space, and at the same time, you omit critical functions that
only the kernel can provide.

> There are at least one AVB-driver (the AV-part of TSN) in the kernel
> already.

And which driver is that?

Thanks,
Richard
