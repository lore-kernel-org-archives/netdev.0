From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 20:14:45 +0300
Message-ID: <55198485.5070107@cogentembedded.com>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519429A.8050000@cogentembedded.com> <5519708E.3040002@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35217 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbC3ROu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:14:50 -0400
Received: by lbdc10 with SMTP id c10so45709905lbd.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 10:14:48 -0700 (PDT)
In-Reply-To: <5519708E.3040002@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/30/2015 06:49 PM, Oliver Hartkopp wrote:

>>> +    /* eliminate multiple filter matches for the same skb */
>>> +    if (*this_cpu_ptr(ro->uniq_skb) == oskb &&
>>> +        ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>>> +            return;

>>     Over-indented.

> I was asked about that before. AFAIK the *skb is no unique identifier over a
> longer period of time. But together with the timestamp it becomes unique.
> Or do you have a better solution to detect identical skbs?

    I just said that *return* was too far to the right, that's all. :-)

> CAN skbs do not have a (rx)hash so far and I wonder if it's worth to compute
> the hash in favor to check the *skb and the timestamp here ...

[...]

> Best regards,
> Oliver

WBR, Sergei
