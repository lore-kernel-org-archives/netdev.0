From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Port attributes configuration
Date: Tue, 29 Jul 2014 06:46:37 -0700
Message-ID: <53D7A5BD.1070805@gmail.com>
References: <CACWm-Bc4=4We1AfnZpL7O5VkUSKjKBZ-NK6edXW2fE5b_u-e7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Varlese <marco.varlese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:37327 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaG2Nqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 09:46:47 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so10361682oag.28
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 06:46:47 -0700 (PDT)
In-Reply-To: <CACWm-Bc4=4We1AfnZpL7O5VkUSKjKBZ-NK6edXW2fE5b_u-e7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/2014 02:15 AM, Marco Varlese wrote:
> I'm working on a new platform and the network interfaces will have
> quite few new options (roughly 50) to configure. What I definitely
> want to achieve is to use the common tools available on Linux to let
> users configure the port attributes from user-space without writing a
> brand new ad-hoc tool.

Its hard to say without knowing what the attributes are and how many
of them are new.

>
> Considered my requirements I think I've a choice of configuring these
> port attributes via:
> 1) ethtool: this I guess will require patches to the tool itself plus
> patches to the kernel to extend the IOCTL calls performed by it;

Many devices already expose many statistics via ethtool -S and features
via ethtool -k. Depending on the attribute it may make sense to add
it here.

> 2) sysfs: adding new files under /sys/class/net/DEVICE/ and handle the
> sysfs extensions in my kernel driver;

Typically most these are read only options. Without knowing your options
I would guess this is the least likely.

> 3) netlink: I understand this seems to be the path most people prefer
> but I think it will require a new tool to be written?
>

Writing a new tool is not necessarily a bad thing IMO but again need
more details what type of options.

> What would you suggest as the best approach here to have a good
> solution accepted by most?

more details.

>
>
> Thanks,
> Marco
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
