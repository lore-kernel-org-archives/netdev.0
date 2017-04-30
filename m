From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 10/10] net: sched: extend gact to allow jumping
 to another filter chain
Date: Sun, 30 Apr 2017 07:08:52 -0400
Message-ID: <5f7aefe4-f283-2eed-d02f-cbfd8e0c29bd@mojatatu.com>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <1493291540-2119-11-git-send-email-jiri@resnulli.us>
 <bedf1246-4900-ebba-cf78-936989029db9@mojatatu.com>
 <20170428065209.GA1886@nanopsycho.orion>
 <a129147c-8992-9de4-e67c-379236b1f012@mojatatu.com>
 <20170428134729.GF1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        mlxsw@mellanox.com, simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36835 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940199AbdD3LIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 07:08:55 -0400
Received: by mail-io0-f195.google.com with SMTP id x86so16960971ioe.3
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 04:08:55 -0700 (PDT)
In-Reply-To: <20170428134729.GF1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-28 09:47 AM, Jiri Pirko wrote:
[..]
> I will try to figure out how to extend GOTO_CHAIN action for other
> actions.
>
> So basically, you suggest to encode chain number into the action opcode,
> like you do it in jump, right? For example:
> #define TC_ACT_GOTO_CHAIN       0x20000000
>
> And then I will have chainlimit 0x10000000-1
>

If you pick a range to own (one that is not being used)
like 0x20000000 then chain limit starts at 0x20000001
to some upper bound. I dont know if you need all the range,
but if you put upper bound to 0x2FFFFFFF that is a few
million.

cheers,
jamal
