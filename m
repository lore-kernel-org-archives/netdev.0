From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] bnx2x: Fix busy_poll vs netpoll
Date: Wed, 15 Apr 2015 10:09:30 -0700
Message-ID: <1429117770.7346.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
	 ,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
	 <1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5B1E@AVMB1.qlogic.org>
	 <1429092351.7346.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF66F2@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35951 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbbDORJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:09:38 -0400
Received: by oift201 with SMTP id t201so32383584oif.3
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 10:09:37 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63CF66F2@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 14:03 +0000, Yuval Mintz wrote:
> > >
> > > BTW, this looks quite generic - isn't it possible to take it out of
> > > the driver and push it into the networking core, uniforming it in the process?
> > 
> > Yes, this is the plan I have in mind, once net-next is opened again ;)
> > 
> > Thanks !
> > 
> 
> I'm not familiar with any real strong test-suite for the busy poll, but I did try
> running all kinds of netperf connections with various busy_{poll,read} values
> and performance seemed reasonable, and verified that netconsole manages
> to work.
> 
> So for all it's worth,
> Tested-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Thanks a lot !
