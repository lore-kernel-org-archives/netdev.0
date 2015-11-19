From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 14:36:48 -0800
Message-ID: <1447972608.22599.281.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	 <20151119.005318.838757439536205791.davem@davemloft.net>
	 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	 <20151119.104811.1447518072450380661.davem@davemloft.net>
	 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
	 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447969982.3054314.444761185.363F62E7@webmail.messagingengine.com>
	 <1447970641.22599.261.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447970956.3057330.444776169.61AEFA6C@webmail.messagingengine.com>
	 <1447971335.22599.268.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447972270.3061531.444784113.21E95CAA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36396 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbKSWgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:36:50 -0500
Received: by pacdm15 with SMTP id dm15so94454969pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:36:49 -0800 (PST)
In-Reply-To: <1447972270.3061531.444784113.21E95CAA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 23:31 +0100, Hannes Frederic Sowa wrote:

> I thought it would be necessary to support multipathing in QUIC?

It is not necessary ;)

There are billions of flows sharing Internet pipes, no need to double
their numbers, it wont help at all.

Simply use one path with appropriate Congestion Control, and it is fine.
