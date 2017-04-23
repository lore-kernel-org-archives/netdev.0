From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 net 3/8] tc/pedit: Introduce 'add' operation
Date: Sun, 23 Apr 2017 13:44:51 -0400
Message-ID: <f358025b-2618-3f22-b593-2e4e70fb7a79@mojatatu.com>
References: <20170423125356.1298-1-amir@vadai.me>
 <20170423125356.1298-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36561 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045819AbdDWRox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 13:44:53 -0400
Received: by mail-it0-f45.google.com with SMTP id g66so33770161ite.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 10:44:53 -0700 (PDT)
In-Reply-To: <20170423125356.1298-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for the excellent work.

On 17-04-23 08:53 AM, Amir Vadai wrote:
> This command could be useful to increase/decrease fields value.
>

Does this contradict the "retain" feature? Example rule to
retain the second nibble but set the first to 0xA
(essentially it X-ORs):
tc filter add dev lo parent ffff: protocol ip prio 10 \
u32 match ip dst 127.0.0.1/32 flowid 1:1 \
action pedit munge offset 0 u8 set 0x0A retain 0xF0

Mostly curious about hardware handling.

cheers,
jamal
