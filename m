From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net bridge: remove unused field
Date: Fri, 18 Oct 2013 06:46:33 -0400
Message-ID: <52611189.7040807@mojatatu.com>
References: <525C5DED.1080406@mojatatu.com> <20131017.161037.310607928835493105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36024 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab3JRKqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 06:46:36 -0400
Received: by mail-ie0-f173.google.com with SMTP id u16so6036244iet.4
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 03:46:35 -0700 (PDT)
In-Reply-To: <20131017.161037.310607928835493105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only reason i made an exception of this one is because:
a) nothing in the kernel touches it
b) nothing in iproute2 touches it
c) the intended logic to transport the hairpin knob is now
in IFLA_BRPORT_MODE

But: I empathize;-> Your call

cheers,
jamal

On 10/17/13 16:10, David Miller wrote:
>
>
> I know it seems rediculous, but anything we export to userspace, as we
> do in this UAPI header, could be potentially be used by some piece of
> source out there.
>
> I'd rather just leave it be, you can add a comment saying it's unused
> if you wish, but I'd really rather not remove it and run the risk of
> breaking someone's build out there.
>
> Thanks.
>
