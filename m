From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 0/9] net: thunderx: Adds XDP support
Date: Wed, 3 May 2017 12:58:25 +0530
Message-ID: <CA+sq2CfW89EbiZmp6byc3y3cbATmmyVB=avzrUXG51-x3yxckg@mail.gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com> <20170502.154744.1762061314370744901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>,
        Sunil Goutham <sgoutham@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33717 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751042AbdECH21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 03:28:27 -0400
In-Reply-To: <20170502.154744.1762061314370744901.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 1:17 AM, David Miller <davem@davemloft.net> wrote:
> From: sunil.kovvuri@gmail.com
> Date: Tue,  2 May 2017 18:36:49 +0530
>
>> From: Sunil Goutham <sgoutham@cavium.com>
>>
>> This patch series adds support for XDP to ThunderX NIC driver
>> which is used on CN88xx, CN81xx and CN83xx platforms.
>>
>> Patches 1-4 are performance improvement and cleanup patches
>> which are done keeping XDP performance bottlenecks in view.
>> Rest of the patches adds actual XDP support.
>
> Series applied, thanks for doing this work.

Thanks.

>
> Do you have any performance numbers?

Below are the forwarding numbers on a single core.
with network stack: 0.32 Mpps
with XDP (XDP_TX): 3 Mpps
and XDP_DROP: 3.8 Mpps

Thanks,
Sunil.
