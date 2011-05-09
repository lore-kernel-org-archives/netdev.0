From: Octavian Purdila <tavi.purdila@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Tue, 10 May 2011 00:46:05 +0300
Message-ID: <BANLkTi=A=iV8eKOH7uqaL8g7hGpjt7XWVw@mail.gmail.com>
References: <891B02256A0667292521A4BF@Ximines.local>
	<1304770926.2821.1157.camel@edumazet-laptop>
	<0F4A638C2A523577CDBC295E@Ximines.local>
	<1304783684.9216.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44369 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab1EIVqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 17:46:06 -0400
Received: by pvg12 with SMTP id 12so2542429pvg.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 14:46:05 -0700 (PDT)
In-Reply-To: <1304783684.9216.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 7, 2011 at 6:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>
> synchronize_rcu() calls are not consuming cpu, they just _wait_
> rcu grace period.
>
> I suggest you read Documentation/RCU files if you really want to :)
>
> If you want to check how expensive it is, its quite easy:
> add a trace in synchronize_net()
>
<snip>

I proposed adding a "wait" software counter to perf [1] a while ago,
which would allow people identify sync_rcu hotspots:

http://marc.info/?l=linux-kernel&m=129188584110162

I don't know how much visibility it got, so given this context, I
thought of bringing it up again :)
