From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RFC PATCH] net/core: support runtime PM on net_device
Date: Wed, 17 Oct 2012 22:17:48 +0800
Message-ID: <CACVXFVOJVVe+PGVBeBaHA1XcJ2s5p3jeqg6=3-6c3ouH70xG0A@mail.gmail.com>
References: <1349873913-10701-1-git-send-email-ming.lei@canonical.com>
	<6849166.biYgaI8vyA@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:51277 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203Ab2JQORu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 10:17:50 -0400
In-Reply-To: <6849166.biYgaI8vyA@vostro.rjw.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 1:07 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Wednesday 10 of October 2012 20:58:33 Ming Lei wrote:
>> In ioctl path on net_device, the physical deivce is often
>> touched, but the physical device may have been put into runtime
>> suspend state already, so cause some utilitis(ifconfig, ethtool,
>> ...) to return failure in this situation.
>>
>> This patch enables runtime PM on net_device and mark it as
>> no_callbacks, and resumes the net_device if physical device
>> is to be accessed, then suspends it after completion of the
>> access.
>>
>> This patch fixes the problem above.
>>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>
> Well, it looks good in principle.
>
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

OK, I will prepare -v1 for merge later if no one has objection on
the patch, which has a compile error.('ret' is not defined in
dev_ethtool)

Thanks,
--
Ming Lei
