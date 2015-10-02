From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Fri, 02 Oct 2015 08:17:39 -0400
Message-ID: <87r3ldmplo.fsf@bytheb.org>
References: <1443733536-992-1-git-send-email-avagin@gmail.com>
	<CANaxB-zvEL6WRNk2Ho7uJUVO8L=t_Nutp9Zxz=Do+Xp1JibHKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33293 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbJBMRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 08:17:43 -0400
Received: by qkas79 with SMTP id s79so41602868qka.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 05:17:42 -0700 (PDT)
In-Reply-To: <CANaxB-zvEL6WRNk2Ho7uJUVO8L=t_Nutp9Zxz=Do+Xp1JibHKw@mail.gmail.com>
	(Andrey Vagin's message of "Fri, 2 Oct 2015 12:04:39 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Vagin <avagin@openvz.org> writes:

> 2015-10-02 0:05 GMT+03:00 Andrey Vagin <avagin@gmail.com>:
>> From: Andrey Vagin <avagin@openvz.org>
>>
>> Now send with MSG_PEEK can return data from multiple SKBs.
>>
>> Unfortunately we take into account the peek offset for each skb,
>> that is wrong. We need to apply the peek offset only once.
>>
>> In addition, the peek offset should be used only if MSG_PEEK is set.
<<snip>>
Agreed here, the behavior is off in the peek offset case.

I was unable to apply your patch, for some reason, but will manually
try to apply it and test.

Thanks very much!
