From: Paul Moore <paul@paul-moore.com>
Subject: Re: Crash in CIPSO_V4_TAG_LOCAL handling
Date: Tue, 17 Jul 2012 12:25:28 -0400
Message-ID: <CAHC9VhQKhoRt8yD4WAgD5tyqjY4bbp4Z4hr5cWfs-d6GJt0pjQ@mail.gmail.com>
References: <1342286550.23395.12.camel@monkey32>
	<20120714.130817.394766887121758073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mlin@ss.pku.edu.cn, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:47901 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab2GQQZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:25:29 -0400
Received: by qadb17 with SMTP id b17so2419547qad.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 09:25:28 -0700 (PDT)
In-Reply-To: <20120714.130817.394766887121758073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 4:08 PM, David Miller <davem@davemloft.net> wrote:
> From: Lin Ming <mlin@ss.pku.edu.cn>
> Date: Sun, 15 Jul 2012 01:22:30 +0800
>
>> It's caused by below code added in commit 15c45f7b.
>>
>>                 case CIPSO_V4_TAG_LOCAL:
>>                         /* This is a non-standard tag that we only allow for
>>                          * local connections, so if the incoming interface is
>>                          * not the loopback device drop the packet. */
>>                         if (!(skb->dev->flags & IFF_LOOPBACK)) {
>>                                 err_offset = opt_iter;
>>                                 goto validate_return_locked;
>>                         }
>
> Paul please fix this, as shown 'skb' can easily be NULL in this
> code path.

Just saw this ... I'll start looking into this today.

-- 
paul moore
www.paul-moore.com
