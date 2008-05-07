From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Tue, 06 May 2008 21:28:29 -0700 (PDT)
Message-ID: <20080506.212829.213490532.davem@davemloft.net>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	<20080425.000547.152086801.davem@davemloft.net>
	<d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753042AbYEGE2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 00:28:34 -0400
In-Reply-To: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Tue, 6 May 2008 20:57:46 -0700

> It may be getting a copy (e.g., when GSO is on?) hence losing all
> its connection to the original tp and any chance to have the pkt
> properly accounted for as host_infligh by TCP. The skb may also be
> cloned more than once (e.g., due to tcpdump)...

It only gets a copy if the SKB is already cloned and that clone is
alive somewhere (f.e. stuck in the device, a rare occurance by
the time we retransmit).

It is a clone %99.999999 of the time.
