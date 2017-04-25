From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Tue, 25 Apr 2017 08:47:00 -0400
Message-ID: <1a05824d-342a-6d06-5fa4-d747a8b8460f@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170424182054.116d1a99@cakuba.netronome.com>
 <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
 <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
 <8f6e7952-b87b-8959-b45a-ab687b69fb1b@mojatatu.com>
 <20170424190743.4ad24ad1@cakuba.netronome.com>
 <20170425115459.GA23939@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36240 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430500AbdDYMrD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:47:03 -0400
Received: by mail-io0-f179.google.com with SMTP id p80so95768613iop.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 05:47:02 -0700 (PDT)
In-Reply-To: <20170425115459.GA23939@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-25 07:55 AM, Simon Horman wrote:
[..]
>
> I agree something should be done wrt BOS. If the LABEL and TC are to
> be left as-is then I think a similar treatment of BOS - that is masking it
> - makes sense.
>
> I also agree with statements made earlier in the thread that it is unlikely
> that the unused bits of these attributes will be used - as opposed to a
> bitmask of flag values which seems ripe for re-use for future flags.
>

For your use case, I think you are fine if you just do the mask in the
kernel. A mask  to a user value implies "I am ignoring the rest
of these bits - I dont  care if you set them "

> I would like to add to the discussion that I think in future it would
> be good to expand the features provided by this patch to support supplying
> a mask as part of the match - as flower supports for other fields such
> as IP addresses. But I think the current scheme of masking out invalid bits
> should also work in conjunction with user-supplied masks.
>

The challenge we have right now is "users do stoopid or malicious
things". So are you going to accept the wrong bitmap + mask?

cheers,
jamal
