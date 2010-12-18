From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Fri, 17 Dec 2010 21:14:15 -0800 (PST)
Message-ID: <20101217.211415.71128810.davem@davemloft.net>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	<20101217195917.33140980@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, therbert@google.com,
	chavey@google.com, ycheng@google.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751179Ab0LRFNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 00:13:46 -0500
In-Reply-To: <20101217195917.33140980@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 17 Dec 2010 19:59:17 -0800

> On Fri, 17 Dec 2010 19:20:51 -0800
> Nandita Dukkipati <nanditad@google.com> wrote:
> 
>> This patch changes the default initial receive window to 10 mss
>> (defined constant). The default window is limited to the maximum
>> of 10*1460 and 2*mss (when mss > 1460).
>> 
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> 
> This needs way more discussion because it makes Linux non-RFC
> breaking the RFC behavior should require explicit user override.
> I also wonder if the magic value 10 should be a sysctl.

He's changing the default receive window not the transmit
congestion window, so there is nothing RFC about this.

But yes he does have to explain himself why this change is
being made, in exhaustive detail.
