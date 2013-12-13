From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 3/6] net_sched: mirred: remove action when the
 target device is gone
Date: Fri, 13 Dec 2013 10:52:10 -0800
Message-ID: <CAM_iQpUYJgHB2aTv_4xGwnZfS+o8ZSbVpsisn7EpvzN21FymaA@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-4-git-send-email-xiyou.wangcong@gmail.com>
	<52AAF895.8090805@mojatatu.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B748D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:65321 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab3LMSwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:52:11 -0500
Received: by mail-oa0-f48.google.com with SMTP id l6so2520668oag.35
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:52:10 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B748D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 4:12 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Jamal Hadi Salim
>> Sent: 13 December 2013 12:08
> ...
>> > -   int                     tcfm_ok_push;
>> > +   unsigned int            tcfm_ok_push:1;
>> > +   unsigned int            tcfm_bind:1;
>>
>> What has the above cleverness got to do with anything you intended?
>
> Not even 'cleverness'.
> Using byte-sized fields is enough to stop the structure growing.
> Bit fields are usually not a good idea at all.
>

They are both boolean, I think it is a waste to use 'int' for both of them.
I am not a fan of bit fields though.
