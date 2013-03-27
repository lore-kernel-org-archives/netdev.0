From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yam: avoid null pointer dereference error
Date: Wed, 27 Mar 2013 13:46:51 -0400 (EDT)
Message-ID: <20130327.134651.702432728001011428.davem@davemloft.net>
References: <1364383174-17708-1-git-send-email-colin.king@canonical.com>
	<1364406257.2922.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, jpr@f6fbb.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab3C0Rqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:46:55 -0400
In-Reply-To: <1364406257.2922.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Mar 2013 17:44:17 +0000

> On Wed, 2013-03-27 at 11:19 +0000, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> yam_open checks if dev is null, however, before that check it
>> accesses some of the fields from dev in a proceeding printk which
>> will cause a null pointer dereference error if dev is nul. Move
>> the printk to after the null check.
> 
> This function will never be called with dev == NULL.

Then let's remove at least that part of the check.
