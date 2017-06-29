From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower offloads
Date: Thu, 29 Jun 2017 17:39:34 +0300
Message-ID: <CAJ3xEMgUQKyf2d0KB1ZKeKVYcNN65X8U0X55riJv2ebs-w2bGg@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34176 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF2Ojf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 10:39:35 -0400
Received: by mail-oi0-f42.google.com with SMTP id l130so13155779oib.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 07:39:35 -0700 (PDT)
In-Reply-To: <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
>
> Previously there was no way of updating flow rule stats after they
> have been offloaded to hardware. This is solved by keeping track of
> stats received from hardware and providing this to the TC handler
> on request.


You are using the term/variable "unmasked_data" across the code, to
make it clear
the keys provided to the driver are masked by the tcflower kernel code
[1] - what do
you mean by unmasked data?

Or.

[1] f93bd17 net/sched: cls_flower: Use masked key when calling HW offloads
