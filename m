From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 22:06:08 -0400
Message-ID: <8f6e7952-b87b-8959-b45a-ab687b69fb1b@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170424182054.116d1a99@cakuba.netronome.com>
 <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
 <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34647 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979853AbdDYCGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 22:06:11 -0400
Received: by mail-io0-f174.google.com with SMTP id a103so205918618ioj.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 19:06:11 -0700 (PDT)
In-Reply-To: <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 10:00 PM, Jamal Hadi Salim wrote:
> On 17-04-24 09:48 PM, Jamal Hadi Salim wrote:

>
> Hrm. maybe I am wrong.
> Lets say user sets all of the 8 bits in BOS,
> what does setting
> key_val->mpls_bos = nla_get_u8 do?
>
> Same with the 20 bits for the label in the u32
> or 3 bit bits in the u8 tc.

The label and tc are masked - maybe just the BOS
needs something similar?

cheers,
jamal
