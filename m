From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v3 1/3] udp: Expand UDP tunnel common APIs
Date: Tue, 26 Aug 2014 22:01:11 -0700
Message-ID: <CACzMAJ+naPV=UjnVBhTEnj8iJQHEpKk78g=AkDR9xnXhOo9xbQ@mail.gmail.com>
References: <1409110530-4383-1-git-send-email-azhou@nicira.com>
	<1409111647.3173.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:56134 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750919AbaH0FBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 01:01:12 -0400
Received: by mail-ob0-f171.google.com with SMTP id wm4so12508300obc.2
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 22:01:12 -0700 (PDT)
In-Reply-To: <1409111647.3173.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 8:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-08-26 at 20:35 -0700, Andy Zhou wrote:
>> Added create_udp_tunnel_socket(), packet receive and transmit,  and
>> other related common functions for UDP tunnels.
>>
>> Per net open UDP tunnel ports are tracked in this common layer to
>> prevent sharing of a single port with more than one UDP tunnel.
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>
> I see some RCU code, but I do not see elementary rules of RCU being
> respected in this patch.

Which RCU rule are you referring to?

>
> Changelogs are a bit terse, and there is not a single comment in this
> code.

I can add more content and comments in the next patch.

> What is going on exactly ?
>

I am trying to refactor some UDP tunnel code so that we don't end up
duplicate a lot of code when adding new UDP based tunnel protocols.
