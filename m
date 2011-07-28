From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH net-next 0/2] vlan:remove duplicate <linux/if_vlan.h>
Date: Thu, 28 Jul 2011 16:48:48 +0800
Message-ID: <4E312270.1020102@gmail.com>
References: <cover.1311841820.git.panweiping3@gmail.com> <20110728.013830.1949919665209265585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53059 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab1G1IrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:47:21 -0400
Received: by qyk29 with SMTP id 29so2615887qyk.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 01:47:21 -0700 (PDT)
In-Reply-To: <20110728.013830.1949919665209265585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2011 04:38 PM, David Miller wrote:
> From: Weiping Pan<panweiping3@gmail.com>
> Date: Thu, 28 Jul 2011 16:37:38 +0800
>
>> As net/8021q/vlan.h already includes<linux/if_vlan.h>,
>> so other files that includes vlan.h need not to include it.
> Please do not do this.
>
> If someone wants to remove this implicit header dependency,
> that someone will need to add all of the includes back.
>
> It is better for people to include all the headers they need,
> rather than rely upon such indirect inclusions.
Ok, thanks.

Weiping Pan
> I am not applying these patches.
>

