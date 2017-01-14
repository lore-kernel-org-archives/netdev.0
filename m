From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH v5 01/13] net: ethernet: aquantia: Make and configuration
 files.
Date: Sat, 14 Jan 2017 11:04:56 -0800
Message-ID: <74f1434e-ef29-0ccc-0c53-4795cb662f44@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
 <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net>
 <f98434b6-1ff5-6959-6591-b28e24307557@gmail.com>
 <5a7c1fcc-2bb7-f41f-e136-8072efca7307@texas.net>
 <6aa256dd-dae4-60f2-ef7c-ef8b8e5b81e2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda6.aus1.datafoundry.com ([209.99.124.137]:56271 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751673AbdANTGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 14:06:01 -0500
In-Reply-To: <6aa256dd-dae4-60f2-ef7c-ef8b8e5b81e2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2017 10:48 AM, Florian Fainelli wrote:
> On 01/14/2017 10:42 AM, David VomLehn wrote:
>> Yes, we did have it that way at one point. But...there is also the
>> kernel philosophy of not putting in something for future expansion; you
>> can always do it later... Honestly, I've vacillated on this particular one.
> (please don't top post). There are several threads at the moment talking
> about renaming driver directory (synopsys/stmmac, mlx5), doing it later
> is certainly a possibility but is really frowned upon, since it will
> later on make the life of people backporting -stable changes a lot harder.
About that top-posting...I agree, but Microsoft has the entire planet 
doing it the other way. They find bottom posting confusing and often 
can't even figure out that you replied. One more reason I've hated 
Microsoft since 1976. So, I suspect I'm not the only one who 
occasionally slips up. My apologies.
>
> Even if there is just one driver at the moment, I would go with a
> dedicated directory for it, there are enough object files that justify
> this choice IMHO.
Good argument.

-- 
David VL
