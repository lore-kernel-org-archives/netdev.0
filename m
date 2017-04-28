From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Fri, 28 Apr 2017 09:41:00 -0400
Message-ID: <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35207 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423545AbdD1NlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:41:03 -0400
Received: by mail-io0-f172.google.com with SMTP id r16so63808130ioi.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 06:41:03 -0700 (PDT)
In-Reply-To: <20170428131155.GA30329@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-28 09:11 AM, Simon Horman wrote:
> On Fri, Apr 28, 2017 at 08:52:56AM -0400, Jamal Hadi Salim wrote:
>> On 17-04-28 08:00 AM, Simon Horman wrote:
>>> Hi,
>>>
>>> this series is intended to avoid false-positives which match
>>> truncated packets against flower classifiers which match on:
>>> * zero L4 ports or;
>
> How would you describe such a rule? The case that is being dealt with is
> one where there is a parse error and thus nothing to match on from a flower
> pov.
>

A default lower prio match all on udp or icmp?

>> Example what would offloading of
>> header_parse_err_action mean?
>
> Why would it need to differ semantically to the implementation in this
> patch? I feel that I am missing something.
>

Unless I misunderstood:
Isnt the issue the dissector that confused something missing L4 ports
and said "port is zero"?

Unless the hardware has the same "bug" as the dissector seems like would
be a different semantic in the h/ware.

cheers,
jamal
