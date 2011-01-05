From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: bridge: check the length of skb after nf_bridge_maybe_copy_header()
Date: Wed, 5 Jan 2011 21:37:28 +0800
Message-ID: <AANLkTikb+o2tXg0uU92Q9foVqX2P49dhJX+umLX=Nhfn@mail.gmail.com>
References: <AANLkTingFk8qJ8tBwSRCxD=9k-0O3GnTv9V9TbF4N=bg@mail.gmail.com>
 <20110103.092214.193706896.davem@davemloft.net> <20110103101533.3f98b311@nehalam>
 <20110103.121336.212692696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54660 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1AENhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 08:37:50 -0500
Received: by fxm20 with SMTP id 20so15022856fxm.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 05:37:49 -0800 (PST)
In-Reply-To: <20110103.121336.212692696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 4, 2011 at 4:13 AM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
>>
>> Because PPPOE happens afterwards and is not part the calculation.
>> The check should be moved until after skb has reached final form.
>
> That works for me.
>

So, is my patch acceptable?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
