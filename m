From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Tue, 16 Feb 2010 06:57:17 -0500
Message-ID: <1266321437.6776.250.camel@bigi>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	 <4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	 <m37hqdcvgm.fsf@ursa.amorsen.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:51565 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab0BPL5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 06:57:20 -0500
Received: by qyk38 with SMTP id 38so1011090qyk.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 03:57:19 -0800 (PST)
In-Reply-To: <m37hqdcvgm.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-16 at 11:43 +0100, Benny Amorsen wrote:

> xfrm ignores policy routing. You can't route IPSEC in Linux. This is
> actually a fairly annoying limitation. The workaround is to do like
> Microsoft: Encapsulate everything in l2tp or gre.

With these patches if you set policy routing mark, have the proper
setting in the skb or socket for the mark then the proper
route will be selected. If you have an SPD + SA added with the
same mark, those will be used right after the route is selected. 
So essentially you have the same mark across.
Does that solve or alleviate the problem?

cheers,
jamal


