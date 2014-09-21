From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: action stats broken?
Date: Sun, 21 Sep 2014 07:50:17 -0700
Message-ID: <541EE5A9.4000207@gmail.com>
References: <541D7E55.6070306@mojatatu.com> <541D9B78.8070505@gmail.com> <541EC5A4.9040600@mojatatu.com> <541EDF03.1050307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:53712 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaIUO5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:57:07 -0400
Received: by mail-oi0-f53.google.com with SMTP id i138so3028448oig.40
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 07:57:07 -0700 (PDT)
In-Reply-To: <541EDF03.1050307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2014 07:21 AM, Jamal Hadi Salim wrote:
> On 09/21/14 08:33, Jamal Hadi Salim wrote:
>> On 09/20/14 11:21, John Fastabend wrote:
>>
>> I have time this morning - I will chase it to double check in case
>> my environment is messed up.
>>
>
> There is something wrong for sure.
> Ruling out kernel regression at this point.
> It is definetely passing the stats.
> Zoning on iproute2.
>
> cheers,
> jamal
>
>

I am using the latest iproute2 tip,

commit eb5d01ff38080935a1a528e4c99cab42bf93d762
Author: Stephen Hemminger <stephen@networkplumber.org>
Date:   Sun Sep 14 20:40:37 2014 -0700

     update dsfield file values

     Update the rt_dsfield file to contain values defined in current RFC.
     The days of TOS precedence are gone, even Cisco doesn't refer
     to these in the documents.

I think you are right might need to bisect iproute2.


-- 
John Fastabend         Intel Corporation
