From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
	window.
Date: Thu, 10 Dec 2009 13:55:43 -0800
Message-ID: <97949e3e0912101355m3404de91o64ec341dc474c33b@mail.gmail.com>
References: <pvm638hum1a.fsf@chavey.mtv.corp.google.com> <87fx7kmg6o.fsf@basil.nowhere.org>
	<65634d660912091001s44016cccq4f2422e613ba9db9@mail.gmail.com>
	<20091209.182131.226771813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: therbert@google.com, andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:45862 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761826AbZLJVz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:55:59 -0500
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id nBALu4b0026894
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 13:56:05 -0800
Received: from qyk31 (qyk31.prod.google.com [10.241.83.159])
	by kpbe18.cbf.corp.google.com with ESMTP id nBALu3H9003780
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 13:56:03 -0800
Received: by qyk31 with SMTP id 31so125008qyk.9
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 13:56:03 -0800 (PST)
In-Reply-To: <20091209.182131.226771813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I like the suggestion, it keeps it in the line of how init_cwnd works now.

On Wed, Dec 9, 2009 at 6:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 9 Dec 2009 10:01:24 -0800
>
>> If we can use larger initial congestion windows on private networks
>> that we know to be
>
> With the keyword here being "network", which is why this must be a
> route attribute not a sysctl with global unilatteral effect.
>
> Otherwise I can tell you what people with both forward and inward
> facing interfaces are going to do, they'll turn the thing on globally
> with your sysctl even though they process real Internet traffic.
>
> No way, we're not going to make it so easy to screw things up.
>
