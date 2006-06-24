From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Sat, 24 Jun 2006 10:30:05 -0400
Message-ID: <1151159405.6716.106.camel@jzny2>
References: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
	 <20060622.155805.35017169.davem@davemloft.net>
	 <1151024186.5099.46.camel@jzny2>  <1151069083.7808.19.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:11186 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750735AbWFXObB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jun 2006 10:31:01 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fu9A7-0006yP-Nb
	for netdev@vger.kernel.org; Sat, 24 Jun 2006 10:31:03 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1151069083.7808.19.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-23-06 at 08:24 -0500, Steve Wise wrote:

> 
> > PS:- I do think what they need is to hear route cache generation
> > as opposed to ARP+FIB updates; but lets wait and see how clever 
> > the patches would look.
> > 

> Can you expand on your statement above?  If hooking route cache
> generation gets all the events I described, then I'd like to use that.
> I'm still learning the Linux routing subsystem.  Any help would be
> GREAT!
> 

If my understanding is correct of what you are trying to do is:
for a destination IP you are going to figure the source and destination
MAC address. Most of that info is available at the route + hh cache. 
There can be only one destination mac per device and so you only need to
watch the device changes for that. The dst MAC per IP and any changes
you can glean from the route cache created.
But this is based on my understanding of what you are trying to do and
so far i cant say i am 100% clear.

cheers,
jamal

