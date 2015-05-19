From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: ethtool: Added port speed macros.
Date: Tue, 19 May 2015 12:32:21 -0400 (EDT)
Message-ID: <20150519.123221.435329742945502707.davem@davemloft.net>
References: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
	<20150518.114630.1938175226193925552.davem@davemloft.net>
	<CAGgvQNT9M-2u_HWn_mYz1sgX4hceTCnbhr1DctQrAPKPNLKq0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: parav.pandit@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbESQc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:32:27 -0400
In-Reply-To: <CAGgvQNT9M-2u_HWn_mYz1sgX4hceTCnbhr1DctQrAPKPNLKq0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@avagotech.com>
Date: Tue, 19 May 2015 10:15:49 +0530

> On Mon, May 18, 2015 at 9:16 PM, David Miller <davem@davemloft.net> wrote:
>> From: Parav Pandit <parav.pandit@avagotech.com>
>> Date: Mon, 18 May 2015 16:31:47 +0530
>>
>>> Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>
>>
>> I thought we had decided that we weren't going to keep adding
>> convenience macros for new speeds, and were simply going to use
>> the appropriate constants in the future.
>>
> 
> I added them to accommodate any speed/PHY interface specific
> configuration to make use of it.
> If convenience macros are not needed, I will provide the code cleanup
> patch to remove existing convenience macros. With that we will have
> unified code for old and new constants.
> I will anyway let Ben comment on it.

You cannot remove the existing macros, because they are exported to
userspace and you'll break application compilation if you do that.
