From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH] virtio_net: fix the potential NULL pointer in xmit_skb()
Date: Fri, 14 Feb 2014 13:25:36 +0800
Message-ID: <CAEH94Lg_Oe77BDWhvJ3BZJsu0ZzaDkr5Rq5RO7oVKjJd75VkcQ@mail.gmail.com>
References: <1392350408-3811-1-git-send-email-wuzhy@linux.vnet.ibm.com>
	<20140214.001252.1994875881466995036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:42403 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaBNFZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 00:25:36 -0500
Received: by mail-yh0-f50.google.com with SMTP id 29so11261842yhl.9
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 21:25:36 -0800 (PST)
In-Reply-To: <20140214.001252.1994875881466995036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 1:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Date: Fri, 14 Feb 2014 12:00:08 +0800
>
>> The pointer hdr isn't assigned before hdr->mhdr and hdr->hdr
>> are used, so it could be one invalid pointer.
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> sizeof(x) does not evaluate any dereferences made by 'x'
thanks for your explanation.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Regards,

Zhi Yong Wu
