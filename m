From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] net: sysctl: fix a kmemleak warning
Date: Fri, 23 Oct 2015 17:54:47 +0800
Message-ID: <CAJFZqHyDyU4biPAjobp9V=CpHKXJvoveCX_cWQjVrLhZ7GiHZw@mail.gmail.com>
References: <1445484432-17673-1-git-send-email-roy.qing.li@gmail.com>
	<20151023.030444.704308961251594308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33048 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbJWJys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:54:48 -0400
Received: by qkcy65 with SMTP id y65so68064098qkc.0
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 02:54:47 -0700 (PDT)
In-Reply-To: <20151023.030444.704308961251594308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 6:04 PM, David Miller <davem@davemloft.net> wrote:
>> +out1:
>> +     unregister_sysctl_table(net_header);
>> +     kfree(net_header);
>
> I read over unregister_sysctl_table() and it appears to do the kfree()
> for us, doesn't it?


you are right, thanks

-Roy
