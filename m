From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 13:52:50 -0700
Message-ID: <20101026135250.74870932@nehalam>
References: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
	<1288124114.2652.25.camel@edumazet-laptop>
	<AANLkTik+s4CHgPuY6uhe-0aD=WJs=UHhoEdok4AyTdYJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56721 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760439Ab0JZUww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 16:52:52 -0400
In-Reply-To: <AANLkTik+s4CHgPuY6uhe-0aD=WJs=UHhoEdok4AyTdYJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Oct 2010 22:26:07 +0200
Kevin Wilson <wkevils@gmail.com> wrote:

> Hi,
> Thanks a lot for your quick answer, I appreciate it (and did not
> expect it to be so quick!)
> 
> Can someone please explain in 2-3 short sentences Why GRO can be
> forwarded and LRO cannot be forwarded ?
> rgs,
> Kevin

LRO merges packets together creating one large skb.  This is a layering
violation for forwarding or bridging (it violates end to end principle).

GRO maintains the headers of each packet and passes them as
a cluster.
