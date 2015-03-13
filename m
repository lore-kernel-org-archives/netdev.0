From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] xps: must clear sender_cpu before forwarding
Date: Thu, 12 Mar 2015 19:57:10 -0700
Message-ID: <1426215430.11398.179.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5500E52C.7080603@nuclearfallout.net>
	 <CANn89iLHkYc2Kay7z+v=tHMW5aYSqUf8V4f70Z-d5fUuuUXnpw@mail.gmail.com>
	 <1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.235134.2179029122534232611.davem@davemloft.net>
	 <55024D36.7040108@nuclearfallout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John <jw@nuclearfallout.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34943 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbCMC5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 22:57:12 -0400
Received: by ieclw3 with SMTP id lw3so77447165iec.2
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 19:57:11 -0700 (PDT)
In-Reply-To: <55024D36.7040108@nuclearfallout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 19:36 -0700, John wrote:

> Running this patch, I have confirmed that I no longer see panics under 
> the conditions that I saw them previously.

Thanks a lot John !
