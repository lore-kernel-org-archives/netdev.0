From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] forcedeth: allow to silence tx_timeout debug
 messages
Date: Wed, 18 May 2011 18:01:23 -0400 (EDT)
Message-ID: <20110518.180123.953614008385558805.davem@davemloft.net>
References: <1305753000-14933-2-git-send-email-decot@google.com>
	<20110518.171603.2048423328863525352.davem@davemloft.net>
	<BANLkTinG4K-bWS1qqBr_G9mK5OHDYknszg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, szymon@janc.net.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com,
	snanda@google.com
To: decot@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189Ab1ERWBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:01:38 -0400
In-Reply-To: <BANLkTinG4K-bWS1qqBr_G9mK5OHDYknszg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@google.com>
Date: Wed, 18 May 2011 14:43:58 -0700

> On Wed, May 18, 2011 at 2:16 PM, David Miller <davem@davemloft.net> wrote:
>> You can add a knob which when enabled gives the old verbosity
>> back for diagnostic purposes.
> 
> That was the intent of this patch: it adds a debug_tx_timeout module
> parameter to act as the knob. I can rephrase the description of the
> patch, it didn't make this so clear.
> Or are you suggesting I should implement this with another kind of knob?

I'm saying implement things differently.

Reduce the verbosity of the TX timeout message but still print some
amount of information, but provide a new knob that turns on the
existing verbose messages.
