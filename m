From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Tue, 26 Oct 2010 08:35:37 -0700 (PDT)
Message-ID: <20101026.083537.226783463.davem@davemloft.net>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
	<201010260818.47523.helmut.schaa@googlemail.com>
	<AANLkTimMrqhWbnLXk1xbYPY7WT7Gazn5G=S1QvVkZ86Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: helmut.schaa@googlemail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751937Ab0JZPfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 11:35:14 -0400
In-Reply-To: <AANLkTimMrqhWbnLXk1xbYPY7WT7Gazn5G=S1QvVkZ86Y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 26 Oct 2010 08:32:59 -0700

>> Wouldn't that break mac80211 QoS again for bridged AP mode interfaces (see
>> commit deabc772f39405054a438d711f408d2d94d26d96, "net: fix tx queue selection
>> for bridged devices implementing select_queue")?
>>
> Yes, looks like that would break.  I'll fix that.
> 
> If a device only has one real TX queue should we still call
> ndo_select_queue, or can we bypass it? (to save one conditional)

Probably bypass, for now.
