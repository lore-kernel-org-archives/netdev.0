From: Parav Pandit <parav.pandit@avagotech.com>
Subject: Re: [PATCH] net-next: ethtool: Added port speed macros.
Date: Tue, 19 May 2015 10:15:49 +0530
Message-ID: <CAGgvQNT9M-2u_HWn_mYz1sgX4hceTCnbhr1DctQrAPKPNLKq0g@mail.gmail.com>
References: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
	<20150518.114630.1938175226193925552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:32802 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbESEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 00:45:50 -0400
Received: by iebgx4 with SMTP id gx4so5302937ieb.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 21:45:49 -0700 (PDT)
In-Reply-To: <20150518.114630.1938175226193925552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 9:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Parav Pandit <parav.pandit@avagotech.com>
> Date: Mon, 18 May 2015 16:31:47 +0530
>
>> Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>
>
> I thought we had decided that we weren't going to keep adding
> convenience macros for new speeds, and were simply going to use
> the appropriate constants in the future.
>

I added them to accommodate any speed/PHY interface specific
configuration to make use of it.
If convenience macros are not needed, I will provide the code cleanup
patch to remove existing convenience macros. With that we will have
unified code for old and new constants.
I will anyway let Ben comment on it.

> Ben?
