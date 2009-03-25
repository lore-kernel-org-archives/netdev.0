From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH 15/61] net: struct device - replace bus_id with
	dev_name(), dev_set_name()
Date: Wed, 25 Mar 2009 10:34:53 +0100
Message-ID: <ac3eb2510903250234r3d648b94xb34e5b0f3b34ef6d@mail.gmail.com>
References: <20090325001659.GA22461@kroah.com>
	 <1237940825-22904-15-git-send-email-gregkh@suse.de>
	 <20090324.232931.65484505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:15423 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754995AbZCYJe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 05:34:56 -0400
In-Reply-To: <20090324.232931.65484505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:29, David Miller <davem@davemloft.net> wrote:
> From: Greg Kroah-Hartman <gregkh@suse.de>
> Date: Tue, 24 Mar 2009 17:26:19 -0700
>
>> From: Kay Sievers <kay.sievers@vrfy.org>
>>
>> Cc: davem@davemloft.net
>> Cc: netdev@vger.kernel.org
>> Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
>> Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
>
> None of this patch applies to net-next-2.6
>
> Probably because, just like the wimax case, these changes
> are already there.

Yeah, I think -next handles duplicate and completely indentical
patches from differnt trees just fine, so that all has been in -next
for a while, and while it was still in Greg's tree when the other tree
merged it.

This patch is in your -next tree:
  http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=db1d7bf70f42124f73675fca62fe32f3ab1111b4

The problem with -next is that if some tree is dropped because of a
non-trivial conflict, and Greg removes merged patches, later patches
in Greg's tree may fail because of missing changes. Maybe we need some
kind of annotation with the -next logic to handle such cases better?

Thanks,
Kay
