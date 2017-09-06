From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 21:04:17 -0700
Message-ID: <CAJieiUjPvte25P0VOdzYgB34TaLN_veTq3PhRc9yse7REmJaCw@mail.gmail.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
 <CAJieiUj_-o-Cg2AzN5b0vrdnBD69ryMmpu4fcC64-MHEmQ-u4g@mail.gmail.com> <59AF291E.90508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:37809 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdIFEET (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 00:04:19 -0400
Received: by mail-vk0-f52.google.com with SMTP id c82so2911737vkd.4
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 21:04:18 -0700 (PDT)
In-Reply-To: <59AF291E.90508@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 3:45 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 09/06/2017 12:01 AM, Roopa Prabhu wrote:
>>
>> On Tue, Sep 5, 2017 at 11:18 AM, Cong Wang <xiyou.wangcong@gmail.com>
>> wrote:
>>>
>>> On Tue, Sep 5, 2017 at 5:48 AM, Nikolay Aleksandrov
>>> <nikolay@cumulusnetworks.com> wrote:
>>>>
>>>> Hi all,
>>>> This RFC adds a new mode for clsact which designates a device's egress
>>>> classifier as global per netns. The packets that are not classified for
>>>> a particular device will be classified using the global classifier.
>>>> We have needed a global classifier for some time now for various
>>>> purposes and setting the single bridge or loopback/vrf device as the
>
>
> Can you elaborate a bit more on the ... "we have needed a global
> classifier for some time now for various purposes".

Most of our acl's are global or use a wildcard. eg iptables supports
global rules without an dev. We do end up having hundreds of netdevs.
Another use case for the future is use of tc for policy based routing
which requires global rules.
