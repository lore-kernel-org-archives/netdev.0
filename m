From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 1/2] dev: introduce dev_cleanup_skb()
Date: Mon, 24 Jun 2013 12:05:50 -0700
Message-ID: <8738s7l46p.fsf@xmission.com>
References: <87y5ijd98e.fsf@xmission.com>
	<1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
	<1372083239-9451-2-git-send-email-nicolas.dichtel@6wind.com>
	<1372097639.1896.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>, <bcrl@kvack.org>,
	<ravi.mlists@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56692 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab3FXTGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 15:06:24 -0400
In-Reply-To: <1372097639.1896.13.camel@bwh-desktop.uk.level5networks.com> (Ben
	Hutchings's message of "Mon, 24 Jun 2013 19:13:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Mon, 2013-06-24 at 16:13 +0200, Nicolas Dichtel wrote:
>> The goal of this new function is to perform all needed cleanup before sending
>> an skb into another netns.
> [...]
>
> To 'cleanup' an object often means to destroy or free it.  So perhaps
> you could find an alternate verb that doesn't have that association,
> e.g. 'sanitise' or 'unmark'.

skb_scrub_packet sounds good to me.    It has the right connotation
and it is shorter. :)

Eric
