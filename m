From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 19:52:05 -0700
Message-ID: <1375930325.4004.88.camel@edumazet-glaptop>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>
	  <1375920752.4004.71.camel@edumazet-glaptop>
	  <5202E510.9060309@candelatech.com>
	 <1375924125.4004.83.camel@edumazet-glaptop>
	 <5202FA51.4040906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:65142 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934042Ab3HHCwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 22:52:07 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so2842325pad.2
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 19:52:07 -0700 (PDT)
In-Reply-To: <5202FA51.4040906@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 18:54 -0700, Ben Greear wrote:

> Maybe we should just do the csum calc in the kernel if packet is
> about to be sent up to user-space via af_packet?  I think that
> would keep the expected behaviour, and hopefully not loose any of the performance
> benefits for cases where the packet never leaves the kernel?

I think you are rephrasing what I suggested ;)

I'll send a patch asap, unless someone beats me.
