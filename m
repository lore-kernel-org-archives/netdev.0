From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/7] skbuff: Add the offload_mr_fwd_mark field
Date: Fri, 29 Sep 2017 08:05:47 +0200
Message-ID: <20170929060547.GA1867@nanopsycho>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-2-jiri@resnulli.us>
 <20170928174903.GE14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com,
        edumazet@google.com, willemb@google.com, johannes.berg@intel.com,
        dcaratti@redhat.com, pabeni@redhat.com, daniel@iogearbox.net,
        f.fainelli@gmail.com, fw@strlen.de, gfree.wind@vip.163.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:51722 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdI2GFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 02:05:49 -0400
Received: by mail-wr0-f172.google.com with SMTP id j14so445339wre.8
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 23:05:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170928174903.GE14940@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 28, 2017 at 07:49:03PM CEST, andrew@lunn.ch wrote:
>On Thu, Sep 28, 2017 at 07:34:09PM +0200, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>> 
>> Similarly to the offload_fwd_mark field, the offload_mr_fwd_mark field is
>> used to allow partial offloading of MFC multicast routes.
>
>> The reason why the already existing "offload_fwd_mark" bit cannot be used
>> is that a switchdev driver would want to make the distinction between a
>> packet that has already gone through L2 forwarding but did not go through
>> multicast forwarding, and a packet that has already gone through both L2
>> and multicast forwarding.
>
>Hi Jiri
>
>So we are talking about l2 vs l3. So why not call this
>offload_l3_fwd_mark?
>
>Is there anything really specific to multicast here?

Currently it is, not sure if it is going to be used for anything else
later on. In case it will be, it could be renamed very easily.


>
>   Thanks
>      Andrew
