From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv3 net-next 0/7] pktgen IPsec support
Date: Mon, 16 Dec 2013 07:41:17 -0500
Message-ID: <52AEF4ED.4020504@mojatatu.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:58417 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LPMlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:41:22 -0500
Received: by mail-ie0-f179.google.com with SMTP id x13so6340992ief.38
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 04:41:22 -0800 (PST)
In-Reply-To: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 02:57, Fan Du wrote:
> Hi, Dave
>
> Current pktgen IPsec supports only transport/ESP combinnation,
> This patchset enables user to do almost any IPsec transformation,
> both transport/tunnel mode, and AH/ESP/IPcomp type.
>
> Below configuration has been tested, and using Wireshark could decrypt
> out plain text in good formation without any checksum/auth errors:
>
> Mode/TYPE   AH  ESP
> Transport   x   x
> Tunnel      x   x
>

Very nice - but i couldnt see which patch added the option to enable
checksums.
I also think that some dose of update to the pktgen documentation in
Documents/  would be useful.

cheers,
jamal
