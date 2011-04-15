From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] ethtool: remove phys_id from ethtool_ops
Date: Fri, 15 Apr 2011 02:08:38 -0700
Message-ID: <BANLkTim51Eip4SnsBFZgdOHjUW0M1kzE2w@mail.gmail.com>
References: <20110408170830.3ab079e8@nehalam>
	<20110414.234654.71103337.davem@davemloft.net>
	<20110414.235736.104051922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48920 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195Ab1DOJIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 05:08:39 -0400
Received: by fxm17 with SMTP id 17so1690807fxm.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:08:38 -0700 (PDT)
In-Reply-To: <20110414.235736.104051922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2011 at 23:57, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 14 Apr 2011 23:46:54 -0700 (PDT)
>
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Fri, 8 Apr 2011 17:08:30 -0700
>>
>>> Hold this patch until after the Intel and Qlogic driver
>>> changes are merged into net-next. Patches have been submitted
>>> but still waiting for vendor.
>>>
>>> After that all the upstream kernel drivers now use phys_id,
>>> and the old ethtool_ops interface (phys_id) can be removed.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> Since everything is now merged, I've applied this.
>
> Actually, it seems we're not ready yet, e1000 still refers
> to phys_id.
>
> Can someone take care of this?

I know that most of our drivers still refer to phys_id, with Bruce's
recent patches to ethtool, we can finish up fixing the patches against
the Intel drivers.  I will make every effort to have patches to you by
Monday/Tuesday.

-- 
Cheers,
Jeff
