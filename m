From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 6/7] net: bridge: Pass extack to down to
 netdev_master_upper_dev_link
Date: Wed, 4 Oct 2017 09:16:20 -0700
Message-ID: <fc657f3d-0a6d-1df1-6373-e170dbdbee25@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
 <1507093134-20406-7-git-send-email-dsahern@gmail.com>
 <20171004081357.37bfd941@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34459 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750937AbdJDQQT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 12:16:19 -0400
Received: by mail-pg0-f67.google.com with SMTP id u27so13507120pgn.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 09:16:19 -0700 (PDT)
In-Reply-To: <20171004081357.37bfd941@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/17 8:13 AM, Stephen Hemminger wrote:
> On Tue,  3 Oct 2017 21:58:53 -0700
> David Ahern <dsahern@gmail.com> wrote:
> 
>> Pass extack arg to br_add_if. Add messages for a couple of failures
>> and pass arg to netdev_master_upper_dev_link.
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> This looks good. You might want to pass the netlink_ext_ack down as
> an immutable pointer (const).

Can't mark extack as const. The NL_SET_ERR_MSG sets _msg to the passed
in string.

> 
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>
> 
