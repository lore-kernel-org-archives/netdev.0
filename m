From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 11:50:10 -0400
Message-ID: <60f33e91-2dfc-e70b-67bc-133484a47e3c@mojatatu.com>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
 <20170504.104103.1628291573330660235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35314 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754503AbdEDPuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:50:22 -0400
Received: by mail-io0-f193.google.com with SMTP id v34so4617379iov.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 08:50:22 -0700 (PDT)
In-Reply-To: <20170504.104103.1628291573330660235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-04 10:41 AM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Thu, 4 May 2017 08:27:35 -0600
>
>> On 5/4/17 3:36 AM, Daniel Borkmann wrote:
>>> What is the clear benefit/rationale of outsourcing this to
>>> libmnl? I always was the impression we should strive for as little
>>> dependencies as possible?
>>
>> +1
>
> Agreed, all else being equal iproute2 should be as self contained
> as possible since it is such a fundamental tool.
>

True, but:->
iproute2 _already_ depends on libmnl;-> (latest user being devlink).

cheers,
jamal
