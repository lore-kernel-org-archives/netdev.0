From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next v3 1/3] udp: Expand UDP tunnel common APIs
Date: Wed, 27 Aug 2014 04:45:24 -0700
Message-ID: <1409139924.3173.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409110530-4383-1-git-send-email-azhou@nicira.com>
	 <1409111647.3173.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACzMAJ+naPV=UjnVBhTEnj8iJQHEpKk78g=AkDR9xnXhOo9xbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:58341 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbaH0Lp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 07:45:28 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so119405pdj.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 04:45:26 -0700 (PDT)
In-Reply-To: <CACzMAJ+naPV=UjnVBhTEnj8iJQHEpKk78g=AkDR9xnXhOo9xbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-08-26 at 22:01 -0700, Andy Zhou wrote:

> Which RCU rule are you referring to?

The most elementary ones, like observing rcu grace period before
freeing ?

udp_tunnel_sock_release() is obviously wrong, or needs an appropriate
documentation.

Please carefully read Documentation/RCU/checklist.txt and tell us why
you believe your code is correct, either in the changelog or using
comments.
