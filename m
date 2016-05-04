From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ensure non-empty connection request queue
Date: Wed, 04 May 2016 10:34:26 -0700
Message-ID: <1462383266.5535.350.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462312458-2077-1-git-send-email-peter@lekensteyn.nl>
	 <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
	 <572A3048.60802@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Kui Zhang <kuizhang@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34724 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbcEDRe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:34:29 -0400
Received: by mail-pf0-f177.google.com with SMTP id y69so27406274pfb.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 10:34:29 -0700 (PDT)
In-Reply-To: <572A3048.60802@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 10:24 -0700, Rick Jones wrote:

> Dropping the connection attempt makes sense, but is entering/claiming 
> synflood really indicated in the case of a zero-length accept queue?

This is a one time message.

This is how people can learn about their user space bugs, or too small
backlog ;)

Being totally silent would be not so nice.
