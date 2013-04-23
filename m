From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 14:52:22 -0700
Message-ID: <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	<1366749094-5982-1-git-send-email-willemb@google.com>
	<20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	<1366753063.8964.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:61291 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab3DWVw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 17:52:28 -0400
Received: by mail-pd0-f177.google.com with SMTP id p11so693576pdj.22
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 14:52:28 -0700 (PDT)
In-Reply-To: <1366753063.8964.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Apr 2013 14:37:43 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2013-04-23 at 14:23 -0700, Stephen Hemminger wrote:
> 
> > What about just having a smarter ingress qdisc?
> 
> What are your ideas ?
> 
> Setting ingress qdisc on linux is no fun, and not scalable.
> 
> Its ok for playing with netem and low bandwidth.
> 
> 

I just don't want to get tied down to one hard coded policy.
User seem have different ideas about what constitutes a flow and what policy for drop should be.
Existing ingress qdisc is inflexible and ifb is a pain to setup and adds
another queue transistion.
