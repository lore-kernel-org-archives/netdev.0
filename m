From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Tue, 31 Jan 2017 22:22:12 -0800
Message-ID: <CAADnVQ+8kCcd8MZYscbFYap6-0DjTp4hek0LPCUfMBA0kt550Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35635 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdBAGWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 01:22:35 -0500
Received: by mail-lf0-f67.google.com with SMTP id v186so35618161lfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:22:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 9:33 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> On Tue, Jan 31, 2017 at 10:36 AM, Andy Gospodarek <andy@greyhouse.net> wrote:
>> On Mon, Jan 30, 2017 at 08:47:47PM -0800, Alexei Starovoitov wrote:
>>> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
>>> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
>>> > and add the basic infrastructure to support XDP.  The 9th patch adds
>>> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
>>> > completes the series with XDP_TX.
>>>
>>> Looks great.
>>> Could you please share performance numbers ?
>>
>> I'll post some later today.
>
> I finally got my system moved around to what I'd hoped would be the
> right spot in my lab, but the system used for generating the traffic
> was only able to send 6Mpps with pktgen, so it was not a great test.
>
> My receiving system with i7-6700 CPU @ 3.40GHz seemed to have no issue
> handling this 6Mpps load -- mpstat showed only one core was ~25%
> utilitzed with all of that servicing softirqs.  The rest of the cores
> were 100% idle.
>
> I'm going to search for other traffic generation tools/systems to make
> sure I can get at least line-rate for the 10GbE cards I was using.

hmm. last time I tried pktgen on bnx2x it was easily doing 14Mpps with burst on.
Have you been using samples/pktgen/pktgen_sample03_burst_single_flow.sh ?
Waiting for this set to land to start benchmarking on bnxt.
So having a baseline will certainly help :)

Thanks!
