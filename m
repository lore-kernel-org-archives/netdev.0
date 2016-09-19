From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 04/10] bnxt_en: Added support for Secure Firmware Update
Date: Mon, 19 Sep 2016 02:03:09 -0700
Message-ID: <CACKFLikYmnWM9WWzAW_9Nqr7FUexMu1H_ObQ0OOVHmvBb14LTQ@mail.gmail.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-5-git-send-email-michael.chan@broadcom.com> <BL2PR07MB23067271DDD44A0E3D31B99A8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35683 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbcISJDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 05:03:10 -0400
Received: by mail-oi0-f41.google.com with SMTP id w11so187850564oia.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 02:03:10 -0700 (PDT)
In-Reply-To: <BL2PR07MB23067271DDD44A0E3D31B99A8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 1:16 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> +     if (bp->hwrm_spec_code < 0x10400)
>> +             return -EOPNOTSUPP;
> Don't you use defines for these kind of version values?

No we don't.  In this case, firmware spec version 1.4.0 has added this
new feature.  So we use this feature if the firmware spec is 1.4.0 or
above.
