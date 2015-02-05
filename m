From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Use static attribute groups for sysfs entries
Date: Thu, 05 Feb 2015 00:33:36 -0800 (PST)
Message-ID: <20150205.003336.2143075755047431035.davem@davemloft.net>
References: <1423057054-6889-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tiwai@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529AbbBEIdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:33:36 -0500
In-Reply-To: <1423057054-6889-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Iwai <tiwai@suse.de>
Date: Wed,  4 Feb 2015 14:37:34 +0100

> Instead of manual calls of device_create_file() and
> device_remove_files(), assign the static attribute groups to netdev
> groups array.  This simplifies the code and avoids the possible
> races.
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

Applied.
