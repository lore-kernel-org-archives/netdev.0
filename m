From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] net: remove useless if check from register_netdevice()
Date: Wed, 12 Feb 2014 18:51:01 +0400
Message-ID: <CAOJe8K338fRKcyDENzTJXQZSo1fvcc5UUuSffnTQnY5-m3qjcA@mail.gmail.com>
References: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
	<20140212.094611.946835062678856302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:58718 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbaBLOvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:51:03 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so10496836obc.6
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 06:51:02 -0800 (PST)
In-Reply-To: <20140212.094611.946835062678856302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/12/14, David Miller <davem@davemloft.net> wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Wed, 12 Feb 2014 11:45:52 +0400
>
>> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>>  	if (dev->netdev_ops->ndo_init) {
>>  		ret = dev->netdev_ops->ndo_init(dev);
>>  		if (ret) {
>> -			if (ret > 0)
>> -				ret = -EIO;
>> +            ret = -EIO;
>>  			goto out;
>>  		}
>
> Like your other patch you are not formatting this code properly at all.
>

I'll resubmit both. Thank you.

> If you cannot insert the correct TAB and space characters necessary
> to indent the code properly, have something help you do it, such as
> emacs's C-mode in "linux" mode.
>
