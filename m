From: Uli Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH 2.6.19-git19] BUG due to bad argument to ieee80211softmac_assoc_work
Date: Thu, 14 Dec 2006 22:38:56 +0100
Message-ID: <341A1CE8-DF10-4CD5-B675-89449256EAB5@deine-taler.de>
References: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:64832 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932940AbWLNVi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 16:38:57 -0500
In-Reply-To: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
To: Michael Bommarito <mjbommar@umich.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

I sent a patch to this list on Sunday, that patched the problem. It  
seems to be migrated into the wireless-2.6 git tree.

Regards,

Uli
Am 13.12.2006 um 19:17 schrieb Michael Bommarito:

> This didn't get much attention on bugzilla and I figured it was
> important enough to forward along to the whole list since it's been
> lingering around in ieee80211-softmac since 19-git5 at least.
> http://bugzilla.kernel.org/show_bug.cgi?id=7657
>
> Somebody was passing the whole mac device structure to
> ieee80211softmac_assoc_work instead of just the assocation work, which
> lead to much death and locking.
>
> Attached is a patch that fixes this (the actual change is two lines
> but context provided in patch for review).  The dmesg containing call
> trace is attached to the bugzilla entry above.
>
> -Mike
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Uli Kunitz



