From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Mon, 12 Jun 2017 13:58:33 -0600
Message-ID: <4d150766-dd1e-26f5-43ea-a3c93cdf291b@gmail.com>
References: <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
 <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
 <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
 <20170612192238.GF1993@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35586 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdFLT6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 15:58:41 -0400
Received: by mail-pf0-f194.google.com with SMTP id s66so2901322pfs.2
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 12:58:40 -0700 (PDT)
In-Reply-To: <20170612192238.GF1993@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/12/17 1:22 PM, Jiri Pirko wrote:
> 
>> 3. IMO since these are nla prefixes and new NLA type they should be in
>> uapi/linux/netlink.h
> Including NLA_* type enum? I think it is reasonable.

well, maybe not the NLA_BITFIELD. That enum is for policy validation
kernel side so not really part of the API.
