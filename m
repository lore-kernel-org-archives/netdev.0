From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:50:20 -0700
Message-ID: <AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
References: <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
 <20101026.102145.246528067.davem@davemloft.net> <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
 <20101026.104710.232747902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:31069 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760167Ab0JZRuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:50:44 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o9QHogAr010600
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:50:43 -0700
Received: from ywj3 (ywj3.prod.google.com [10.192.10.3])
	by kpbe12.cbf.corp.google.com with ESMTP id o9QHofPa001626
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:50:41 -0700
Received: by ywj3 with SMTP id 3so3284334ywj.16
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:50:41 -0700 (PDT)
In-Reply-To: <20101026.104710.232747902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
> Why would you do this when there are link layer indications that
> we are attached to a different network?

Are there? For wifi you could look at the SSID (though even that is no
guarantee - for example enterprise networks commonly use just a few
SSIDs, but have different IP address ranges on a per-controller or
per-radio basis). But what about wired? Remember, the same thing
happens when you unplug your laptop's ethernet port and plug it in to
another network.
