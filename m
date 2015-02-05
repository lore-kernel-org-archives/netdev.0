From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Use static attribute groups for sysfs
 entries
Date: Thu, 05 Feb 2015 00:33:41 -0800 (PST)
Message-ID: <20150205.003341.1777214952985749347.davem@davemloft.net>
References: <1423057135-6939-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: tiwai@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037AbbBEIdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:33:42 -0500
In-Reply-To: <1423057135-6939-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Iwai <tiwai@suse.de>
Date: Wed,  4 Feb 2015 14:38:55 +0100

> Instead of manual calls of device_create_file() and
> device_remove_files(), assign the static attribute groups to netdev
> groups array.  This simplifies the code and avoids the possible
> races.
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

Applied.
