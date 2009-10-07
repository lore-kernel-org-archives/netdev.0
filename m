From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000_eth: Duplicate test of RX_OVERLEN bit in
 update_rx_stats()
Date: Wed, 07 Oct 2009 03:44:54 -0700 (PDT)
Message-ID: <20091007.034454.156559196.davem@davemloft.net>
References: <4ACBA06A.6050208@gmail.com>
	<f861ec6f0910061253g28743e80r2db772aa7101f098@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, manuel.lauss@gmail.com
To: manuel.lauss@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758389AbZJGKo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:44:59 -0400
In-Reply-To: <f861ec6f0910061253g28743e80r2db772aa7101f098@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@googlemail.com>
Date: Tue, 6 Oct 2009 21:53:50 +0200

> On Tue, Oct 6, 2009 at 9:54 PM, Roel Kluin <roel.kluin@gmail.com> wrote:
>> in update_rx_stats() the RX_OVERLEN bit is set twice, replace it by RX_RUNT.
>> in au1000_rx() the RX_MISSED_FRAME bit was tested a few lines earlier already
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
 ...
> 
> Yeah, looks right.
> 
> Acked-by: Manuel Lauss <manuel.lauss@gmail.com>

Applied, thanks.
