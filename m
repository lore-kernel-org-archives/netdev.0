From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: Re: [PATCH V2 18/22] bnxt_re: Support for DCB
Date: Tue, 13 Dec 2016 11:55:55 +0530
Message-ID: <CA+sbYW1irBd0cTqJJSGJWRbBi-iFzvX3JpoTfF_daU47EqNtAg@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <1481266096-23331-19-git-send-email-selvin.xavier@broadcom.com> <CAJ3xEMjcKRZpBMEBwQMZO5OqbVzH2=Q3FOAyYUVAz+ouw1jTNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:32861 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbcLMGZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 01:25:56 -0500
Received: by mail-qk0-f180.google.com with SMTP id x190so107130396qkb.0
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 22:25:56 -0800 (PST)
In-Reply-To: <CAJ3xEMjcKRZpBMEBwQMZO5OqbVzH2=Q3FOAyYUVAz+ouw1jTNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 10, 2016 at 7:20 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Fri, Dec 9, 2016 at 8:48 AM, Selvin Xavier
> <selvin.xavier@broadcom.com> wrote:
>> This patch queries the configured RoCE APP Priority on the host
>> using the dcbnl API and programs the RoCE FW with the corresponding
>> Traffic Class(es) for the priority.
>
>> +#define BNXT_RE_ROCE_V1_ETH_TYPE       0x8915
>> +#define BNXT_RE_ROCE_V2_PORT_NO                4791
>
> I believe these two are defined already, try # git grep on each under include

Thanks Or for your comments.
V2 port number is defined in ib_verbs.h.  i will include this in the
next patch set.
v1 eth_type is not defined. All vendor drivers have their own definition.

Thanks,
Selvin
