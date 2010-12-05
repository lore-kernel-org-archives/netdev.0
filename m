From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 05 Dec 2010 09:27:11 -0500
Message-ID: <1291559231.2159.684.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <1291474127.2159.35.camel@mojatatu> <20101204154007.GA1981@del.dom.local>
	 <1291478881.2159.70.camel@mojatatu> <20101204165609.GB1981@del.dom.local>
	 <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44862 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab0LEO10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 09:27:26 -0500
Received: by yxt3 with SMTP id 3so5054286yxt.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 06:27:26 -0800 (PST)
In-Reply-To: <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-05 at 08:22 +0800, Changli Gao wrote:
> On Sun, Dec 5, 2010 at 12:56 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> >
> > I'm simply not convinced this kind of (fast) throttling can properly
> > fix any of the problems (what about other flows in the queue), while
> > Changli's patch makes this tasklet simpler and a bit faster.
> >
> 
> The error case handled currently is the original netdev disappears but
> the corresponding skbs are still in ifb.
> 
> I do also think checking the return value of netif_rx() and
> dev_queue_xmit() can fix more 'problems'. :)


Please proceed with a patch for that as well..

cheers,
jamal

PS:- We forgot to thank Jarek for pointing out the bug.



