From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH net] filter: prevent nla extensions to peek beyond the end
 of the message
Date: Mon, 14 Apr 2014 07:53:33 +0200
Message-ID: <CA+rthh_oRx7OJOK0eXRt_-mG19+PX8BAAK+y7aa4ymwYhtjtCQ@mail.gmail.com>
References: <1397406213-15452-1-git-send-email-minipli@googlemail.com>
	<20140413.233315.1770347585792751275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:41763 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbaDNFxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 01:53:35 -0400
Received: by mail-la0-f48.google.com with SMTP id gf5so5187572lab.7
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2014 22:53:34 -0700 (PDT)
In-Reply-To: <20140413.233315.1770347585792751275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2014 05:33, David Miller <davem@davemloft.net> wrote:
> From: Mathias Krause <minipli@googlemail.com>
> Date: Sun, 13 Apr 2014 18:23:33 +0200
>
>> The BPF_S_ANC_NLATTR and BPF_S_ANC_NLATTR_NEST extensions fail to check
>> for a minimal message length before testing the supplied offset to be
>> within the bounds of the message. This allows the subtraction of the nla
>> header to underflow and therefore -- as the data type is unsigned --
>> allowing far to big offset and length values for the search of the
>> netlink attribute.
>>
>> The remainder calculation for the BPF_S_ANC_NLATTR_NEST extension is
>> also wrong. It has the minuend und subtrahend mixed up, therefore
>
> I translated the German into English here, re: und --> and :-)
>

Ups! :D Thanks for the review!

Cheers,
Mathias
