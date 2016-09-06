From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Centralizing support for TCAM?
Date: Tue, 6 Sep 2016 09:36:57 -0400
Message-ID: <62b53e5d-a862-a5a2-88d4-9d10577e4274@mojatatu.com>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
 <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com> <57C9C9BE.6040407@gmail.com>
 <20160903070950.GA1749@nanopsycho.orion>
 <20160906034450.GA34929@ast-mbp.thefacebook.com>
 <4e871929-b8fb-b1c9-6909-218460e21e76@mojatatu.com>
 <20160906133105.GD2719@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, jiri@mellanox.com, idosh@mellanox.com,
        john.fastabend@intel.com, ast@kernel.org, davem@davemloft.net,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33280 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIFNg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 09:36:59 -0400
Received: by mail-oi0-f48.google.com with SMTP id y2so71682792oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 06:36:58 -0700 (PDT)
In-Reply-To: <20160906133105.GD2719@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-06 09:31 AM, Andrew Lunn wrote:

> So if i'm reading this right, you are talking about big switches, top
> of racks, etc. And you don't see much use for the TCAM.
>
> Florian and I are interested in the other end of the scale. Little
> 5-10 port switches in SoHo, STB, WiFi Access points etc. At the
> moment, firewalling in such devices is done by the CPU. If we can
> offload some of the firewall rules to the TCAM, we would be happy.
>

As with all discussions on netdev, that was a distraction;->
Use tc as mentioned by Jiri. Please please no ethtool.

cheers,
jamal
