From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should
 conform to RFC5482
Date: Wed, 09 Aug 2017 17:52:10 -0700 (PDT)
Message-ID: <20170809.175210.1390938117227894190.davem@davemloft.net>
References: <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
        <20170809.173032.660035274684914457.davem@davemloft.net>
        <19024bb3-c06b-d004-5527-e4c54af66003@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: codesoldier1@gmail.com, hkchu@google.com, ycheng@google.com,
        kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: rao.shoaib@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbdHJAwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:52:12 -0400
In-Reply-To: <19024bb3-c06b-d004-5527-e4c54af66003@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rao Shoaib <rao.shoaib@oracle.com>
Date: Wed, 9 Aug 2017 17:47:57 -0700

> 
> 
> On 08/09/2017 05:30 PM, David Miller wrote:
>> From: Joe Smith <codesoldier1@gmail.com>
>> Date: Wed, 9 Aug 2017 17:20:32 -0700
>>
>>> Making Linux conform to standards and behavior that is logical seems
>>> like a good enough reason.
>> That's an awesome attitude to have when we're implementing something
>> new and don't have the facility already.
>>
>> But when we have something already the only important consideration is
>> not breaking existing apps which rely on that behavior.
>>
>> That is much, much, more important than standards compliance.
>>
>> If users are confused, just fix the documentation.
> David,
> 
> If it was just confusion than sure fixing the documentation is
> fine. What if the logic is incorrect, does not conform to the standard
> that is says it is implementing and easy to fix with little or no risk
> of breakage.
> 
> The proposed patch changes a feature that no one uses. It also imposes
> the relation ship between keepalive and timeout values that is
> required by the RFC and make sense.
> 
> You are the final authority, if you say we should just fix the
> documentation than that is fine.

I want to hear more about what hkchu and ycheng have to say about
this.
