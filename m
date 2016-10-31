From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: mv643xx_eth.c merge gone bad...
Date: Mon, 31 Oct 2016 11:18:54 -0700
Message-ID: <efd31e03-7d18-a41e-bf7f-3c77faa6e825@gmail.com>
References: <20161031113349.GA8951@lunn.ch>
 <20161031.091206.236633139585216348.davem@davemloft.net>
 <20161031133538.GB9441@lunn.ch>
 <20161031.103403.293968855937308643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe@obsidianresearch.com, jarod@redhat.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34394 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943587AbcJaSS5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:18:57 -0400
Received: by mail-pf0-f195.google.com with SMTP id y68so3480564pfb.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 11:18:57 -0700 (PDT)
In-Reply-To: <20161031.103403.293968855937308643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 07:34 AM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Mon, 31 Oct 2016 14:35:38 +0100
> 
>> On Mon, Oct 31, 2016 at 09:12:06AM -0400, David Miller wrote:
>>> From: Andrew Lunn <andrew@lunn.ch>
>>> Date: Mon, 31 Oct 2016 12:33:49 +0100
>>>
>>>> The merge of commit 27058af401e49d88a905df000dd26f443fcfa8ce for
>>>> mv643xx_eth.c has gone bad:
>>>
>>> Sorry this should be fixed now.
>>
>> Hi David
>>
>> I think the SET_NETDEV_DEV() should be removed, which is what cause the merged conflict:
>>
>> http://patchwork.ozlabs.org/patch/687294/

The SET_NETDEV_DEV() is required for Jason's change to work, since he is
doing this:

+static int get_phy_mode(struct mv643xx_eth_private *mp)
+{
+	struct device *dev = mp->dev->dev.parent;


-- 
Florian
