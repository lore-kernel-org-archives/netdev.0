From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC V3 PATCH 03/26] net/netpolicy: get device queue irq information
Date: Tue, 13 Sep 2016 06:14:13 -0700
Message-ID: <CAKgT0Uf+guzBrfPUFvMk0RnXbQOJUjkBUp0TeK9HOSb_LU7e8Q@mail.gmail.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
 <1473692159-4017-4-git-send-email-kan.liang@intel.com> <665fd0a7-fe83-742a-28fd-d597b28505b5@cogentembedded.com>
 <37D7C6CF3E00A74B8858931C1DB2F07750BBF530@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "gorcunov@openvz.org" <gorcunov@openvz.org>,
        "john.stultz@linaro.org" <john.stultz@linar
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34736 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbcIMNOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 09:14:15 -0400
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07750BBF530@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 5:23 AM, Liang, Kan <kan.liang@intel.com> wrote:
>>
>> Hello.
>>
>> On 09/12/2016 05:55 PM, kan.liang@intel.com wrote:
>>
>> > From: Kan Liang <kan.liang@intel.com>
>> >
>> > Net policy needs to know device information. Currently, it's enough to
>> > only get irq information of rx and tx queues.
>> >
>> > This patch introduces ndo ops to do so, not ethtool ops.
>> > Because there are already several ways to get irq information in
>> > userspace. It's not necessory to extend the ethtool.
>>
>>     Necessary.
>
> OK. I will extend the ethtool in next version.
>
> Thanks,
> Kan

Kan, I don't think Sergei was saying you have to extend the ethtool.
Your spelling of necessary was incorrect in your patch description.

Sergei, please feel free to tell me I am wrong if my assumption on
that is incorrect.

- Alex
