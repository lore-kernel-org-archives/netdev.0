From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 11:28:48 +0200
Message-ID: <1340184528.4604.849.camel@edumazet-glaptop>
References: <4FE0EA33.1000309@profihost.ag>
	 <1340141493.4604.773.camel@edumazet-glaptop>
	 <4FE17522.5050005@profihost.ag>
	 <1340176940.4604.801.camel@edumazet-glaptop>
	 <4FE1881B.7030800@profihost.ag>
	 <1340181676.4604.838.camel@edumazet-glaptop>
	 <4FE192A1.6000000@profihost.ag>  <4FE193FA.5030802@profihost.ag>
	 <1340183854.4604.847.camel@edumazet-glaptop>
	 <4FE196F4.3040900@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37369 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376Ab2FTJ2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:28:53 -0400
Received: by bkcji2 with SMTP id ji2so5948977bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 02:28:52 -0700 (PDT)
In-Reply-To: <4FE196F4.3040900@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 11:25 +0200, Stefan Priebe - Profihost AG wrote:
> Am 20.06.2012 11:17, schrieb Eric Dumazet:
> > On Wed, 2012-06-20 at 11:12 +0200, Stefan Priebe - Profihost AG wrote:
> >> Am 20.06.2012 11:06, schrieb Stefan Priebe - Profihost AG:
> >>>> You seem to have a switch or something that drops packets in this case.
> >>>> You could try to rate limit to 9Gb/s and see if it is better.
> >>> Sadly i can't rate limit to 9Gbit/s on the switch.
> 
> > If you exchange sender/receiver role between linux kernel versions, is
> > it the same problem ?
> I'm testing in both directions. So both are sending and receiving.
> 
> I've now made tests with only one sending an the other receiving.
> 
> When server B is the sender i get 4Gbit/s. When server A is the sender i 
> get full 9,9Gbit/s.
> 
> Stefan

To rule out bad hardware, could you try a 3.5-rc3 kernel on B ?
