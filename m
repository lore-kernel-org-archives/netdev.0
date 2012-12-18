From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Tue, 18 Dec 2012 19:40:36 +0100
Message-ID: <20121218184036.GB1690@minipsycho.orion>
References: <20121218150407.GB1533@minipsycho.orion>
 <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
 <20121218175409.GA1690@minipsycho.orion>
 <CANn89iJdROkJ+dZgfDB9wPpQ3wXdUHK7SX=C2iUbHxwh9=5orw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>, jhs@mojatatu.com,
	davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:33657 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab2LRSkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 13:40:41 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so558199eek.2
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 10:40:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CANn89iJdROkJ+dZgfDB9wPpQ3wXdUHK7SX=C2iUbHxwh9=5orw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 18, 2012 at 07:06:53PM CET, edumazet@google.com wrote:
>> No such messages in log
>>
>>>Also turn off TSO since it screws up any form of rate control.
>>
>> Turning off TSO did not help. However, turning off scatter-gather
>> helped, on both HP DL360G8 (igb) and IBM JS22 (ehea).
>>
>
>Think to also disable GSO

On rhel6 kernel (2.6.32-based) I have to disable GSO as well.

The question is: Is this a bug or is it mandatory to get this offload
disabled in order to TBF to be working correctly?

Thanks a bunch.

Jiri

>
>Alternatively, you can use "mtu 65536" to allow TBF to send packets
>bigger than 2048 bytes
