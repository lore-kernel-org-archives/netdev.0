From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 08:44:40 -0400
Message-ID: <1151412280.6516.35.camel@jzny2>
References: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
	 <20060622.155805.35017169.davem@davemloft.net>
	 <1151024186.5099.46.camel@jzny2>  <1151069083.7808.19.camel@stevo-desktop>
	 <1151159405.6716.106.camel@jzny2>  <1151332486.2398.20.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	caitlinb@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:32673 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932209AbWF0Mon
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 08:44:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FvCvt-00025e-9Q
	for netdev@vger.kernel.org; Tue, 27 Jun 2006 08:44:45 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1151332486.2398.20.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-26-06 at 09:34 -0500, Steve Wise wrote:
> On Sat, 2006-06-24 at 10:30 -0400, jamal wrote:

> The route/hh cache insertions might work for the initial dst MAC per
> next-hop IP.  But this dst MAC can _change_ for various reasons (even
> though the next-hop IP remains the same).   Such a change, I think,
> doesn't generate a new route + hh cache insertion, just a change to the
> hh entry.
> 
> Also, I think the route cache entry is created _before_ the MAC addr is
> known. So we really need to know when the neighbour entry is updated
> with the MAC address as a result of ARP/ND.  Hooking the correct spot in
> the neighbour code where the mac address gets stored also gets us the
> change event I described above.
> 
> Does this make sense?
> 

no - but as long as you solve the problem it should be fine. 
[My goal was to help -factoring in some experiences- it seems you have
it under control though].

cheers,
jamal

