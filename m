From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Using skb->mark outside netfilter
Date: Tue, 07 May 2013 09:30:04 -0400
Message-ID: <518901DC.2050100@mojatatu.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com> <20130506184817.GA2729@open-mesh.com> <5188FBD2.5090200@mojatatu.com> <20130507132326.GB2729@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57187 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757751Ab3EGNaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 09:30:07 -0400
Received: by mail-ie0-f180.google.com with SMTP id ar20so879129iec.25
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 06:30:06 -0700 (PDT)
In-Reply-To: <20130507132326.GB2729@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-05-07 09:23 AM, Antonio Quartulli wrote:

> The mark is not really encoded in the batman header.
>
> Each node is configured with a mark value (the values have to be the same on
> everynode in order to make the mechanism work correctly), then batman-adv will
> advertise to the rest of the mesh which host is sending marked packets.
>
[..]
> Receiving nodes will then restore the mark in the skb each time it is coming from
> one of those advertised hosts.
>

I see - so some control "protocol" will be used to advertise the mark
and which host will use such a mark? Or are you saying some admin is
going around and configuring 100 batman nodes? ;->

Note: I have no freaking clue in regards to batman or its usage.

> A future feature may consists in carrying the mark directly into the header so
> that batman-adv itself does not have to take care about the meaning of such
> value but will just carry it (we still have to think about it...it is just an
> idea now)
>

I think that may be more interesting because it may allow you to use
many different marks with many different meanings. It doesnt disqualify
a control protocol advertising the mark.

cheers,
jamal
