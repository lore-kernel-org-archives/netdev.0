From: Ben Greear <greearb@candelatech.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Wed, 14 Jun 2017 15:23:00 -0700
Message-ID: <4b65e262-e727-010a-ce1f-eb45fcef8e42@candelatech.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
 <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
 <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54130 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752692AbdFNWXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 18:23:01 -0400
In-Reply-To: <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2017 07:27 PM, David Ahern wrote:

> Let's try a targeted debug patch. See attached

I had to change it to pr_err so it would go to our serial console
since the system locked hard on crash,
and that appears to be enough to change the timing where we can no longer
reproduce the problem.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
