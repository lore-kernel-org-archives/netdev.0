From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED
 qdisc
Date: Mon, 30 Oct 2017 13:24:20 -0600
Message-ID: <c02f7bb1-b534-64fb-8beb-d5f379773fab@gmail.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
 <20171030085613.8697-2-jiri@resnulli.us>
 <20171030.212015.742241045938302800.davem@davemloft.net>
 <DB5PR05MB18954A4B8E0C9F9300F3EE59AC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>, "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "pieter.jansenvanvuuren@netronome.com"
        <pieter.jansenvanvuur
To: Nogah Frankel <nogahf@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:55422 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbdJ3TYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 15:24:24 -0400
Received: by mail-pg0-f46.google.com with SMTP id 15so12473777pgc.12
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 12:24:24 -0700 (PDT)
In-Reply-To: <DB5PR05MB18954A4B8E0C9F9300F3EE59AC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/17 7:54 AM, Nogah Frankel wrote:
>>> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>>> index 0e88cc2..743c42a 100644
>>> --- a/include/uapi/linux/pkt_sched.h
>>> +++ b/include/uapi/linux/pkt_sched.h
>>> @@ -255,6 +255,7 @@ struct tc_red_qopt {
>>>  #define TC_RED_ECN		1
>>>  #define TC_RED_HARDDROP		2
>>>  #define TC_RED_ADAPTATIVE	4
>>> +#define TC_RED_OFFLOADED	8
>>>  };
>>>
>>>  struct tc_red_xstats {
>>
>> What keeps a user from setting this flag in the tc_red_qopt it
>> passes into the a change operation?
> 
> Nothing keeps the user from doing it, but it has no effect.
> The decision to offload is the driver's only.
> It is basically a read-only flag.
> 

If it is read-only, then attempts to set it from userspace should cause
the command to fail.
