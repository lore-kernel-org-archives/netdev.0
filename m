From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] net: enable interface alias removal via rtnl
Date: Wed, 11 Oct 2017 14:29:16 +0200
Message-ID: <8b334f53-235b-42d2-ba68-4e63c54c498c@6wind.com>
References: <1cccbbaa-455b-66e0-a447-7f7e3b3bb375@gmail.com>
 <20171010124138.27342-1-nicolas.dichtel@6wind.com>
 <c81359e7-feb8-475e-69d7-3eacc3406caf@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, oliver@hartkopp.net,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:48103 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757371AbdJKM3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 08:29:20 -0400
Received: by mail-wm0-f44.google.com with SMTP id t69so4260447wmt.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 05:29:19 -0700 (PDT)
In-Reply-To: <c81359e7-feb8-475e-69d7-3eacc3406caf@gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/10/2017 à 16:50, David Ahern a écrit :
> On 10/10/17 6:41 AM, Nicolas Dichtel wrote:
>> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
>> the attribute is 1 ("\0"). However, to remove an alias, the attribute
>> length must be 0 (see dev_set_alias()).
>>
>> Let's define the type to NLA_BINARY, so that the alias can be removed.
> 
> not to be pedantic, but we need to be clear that the type is changed
> only for policy validation.
With the comment in the code, it is clear, isn't it?


Regards,
Nicolas
