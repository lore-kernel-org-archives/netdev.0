From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: add support for Marvell Alaska M88E1118R PHY
Date: Wed, 19 Jan 2011 22:51:50 -0800
Message-ID: <AANLkTinDh-ZnrZy3f5H72+FuNwvbnY-BnCns17+cpR=Z@mail.gmail.com>
References: <201101191009.44707.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dirk Brandewie <dirk.j.brandewie@intel.com>
To: Florian Fainelli <ffainelli@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44795 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab1ATGvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 01:51:51 -0500
Received: by iyj18 with SMTP id 18so254560iyj.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 22:51:50 -0800 (PST)
In-Reply-To: <201101191009.44707.ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 01:09, Florian Fainelli <ffainelli@freebox.fr> wrote:
> From: Florian Fainelli <ffainelli@freebox.fr>
>
> This patch adds support for Marvell Alask M88E188R PHY chips. Support for
> other M88* PHYs is already there, so there is nothing more to add than its
> PHY id.
>
> Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
> CC: Dirk Brandewie <dirk.j.brandewie@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

The patch itself looks fine.  I am concerned about validation.

Dirk - is there a chance that the ce4100 will use this PHY?  If so,
can you cover the validation?

For now I will add this to my net-next tree while I await word from Dirk.

-- 
Cheers,
Jeff
