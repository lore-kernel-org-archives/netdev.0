From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 10:17:56 -0700
Message-ID: <1432833476.7456.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <5567382E.4010706@gmail.com>
	 <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <133859123.129202.1432830817627.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33692 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbE1RSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 13:18:01 -0400
Received: by iebgx4 with SMTP id gx4so43625116ieb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 10:18:01 -0700 (PDT)
In-Reply-To: <133859123.129202.1432830817627.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 12:33 -0400, jsullivan@opensourcedevel.com wrote:

> Our initial testing has been single flow but the ultimate purpose is processing
> real time video in a complex application which ingests associated meta data,
> post to consumer facing cloud, does reporting back - so lots of different
> traffics with very different demands - a perfect tc environment.

Wait, do you really plan using TCP for real time video ?
