From: Eric Dumazet <edumazet@google.com>
Subject: Re: inaccurate packet scheduling
Date: Tue, 18 Dec 2012 10:06:53 -0800
Message-ID: <CANn89iJdROkJ+dZgfDB9wPpQ3wXdUHK7SX=C2iUbHxwh9=5orw@mail.gmail.com>
References: <20121218150407.GB1533@minipsycho.orion>
	<e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
	<20121218175409.GA1690@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>, jhs@mojatatu.com,
	davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:43680 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab2LRSGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 13:06:53 -0500
Received: by mail-ie0-f178.google.com with SMTP id c12so1353569ieb.37
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 10:06:53 -0800 (PST)
In-Reply-To: <20121218175409.GA1690@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No such messages in log
>
>>Also turn off TSO since it screws up any form of rate control.
>
> Turning off TSO did not help. However, turning off scatter-gather
> helped, on both HP DL360G8 (igb) and IBM JS22 (ehea).
>

Think to also disable GSO

Alternatively, you can use "mtu 65536" to allow TBF to send packets
bigger than 2048 bytes
