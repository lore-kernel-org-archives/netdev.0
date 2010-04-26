From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 17:11:37 -0400
Message-ID: <1272316297.8918.49.camel@bigi>
References: <u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com>
	 <20100426.112244.260086869.davem@davemloft.net> <4BD5F553.6020006@hp.com>
	 <20100426.134051.232750473.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:49130 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab0DZVLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:11:40 -0400
Received: by pvg2 with SMTP id 2so708795pvg.19
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 14:11:39 -0700 (PDT)
In-Reply-To: <20100426.134051.232750473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-26 at 13:40 -0700, David Miller wrote:

> Why do you think Eric Dumazet gives a crap about UDP scalability and
> is constantly testing it?  What about VOIP?  H.323, RTP, etc.?

This is big of course. All the SIP/RTP stuff is largely UDP. Most P2P
control is via UDP. I think i did read somewhere on measurement taken
in backbones showing consistent rise of UDP:TCP ratio (need to search
my bookmarks). 
It borders on lunacy to assume TCP only. Time to get an open source NIC
out there and ignore these big players? ;->

cheers,
jamal

