From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next 1/2] dev: introduce dev_cleanup_skb()
Date: Mon, 24 Jun 2013 19:13:59 +0100
Message-ID: <1372097639.1896.13.camel@bwh-desktop.uk.level5networks.com>
References: <87y5ijd98e.fsf@xmission.com>
	 <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1372083239-9451-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<ebiederm@xmission.com>, <bcrl@kvack.org>, <ravi.mlists@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37157 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab3FXSOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 14:14:04 -0400
In-Reply-To: <1372083239-9451-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 16:13 +0200, Nicolas Dichtel wrote:
> The goal of this new function is to perform all needed cleanup before sending
> an skb into another netns.
[...]

To 'cleanup' an object often means to destroy or free it.  So perhaps
you could find an alternate verb that doesn't have that association,
e.g. 'sanitise' or 'unmark'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
