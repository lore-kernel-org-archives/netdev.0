From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sat, 24 Apr 2010 12:22:30 -0400
Message-ID: <1272126150.8918.20.camel@bigi>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
	 <1272125052.8918.18.camel@bigi>
	 <q2i412e6f7f1004240919la9825819i81a4d3063ed781a5@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:63853 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0DXQWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 12:22:34 -0400
Received: by qyk9 with SMTP id 9so14845851qyk.1
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 09:22:34 -0700 (PDT)
In-Reply-To: <q2i412e6f7f1004240919la9825819i81a4d3063ed781a5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-25 at 00:19 +0800, Changli Gao wrote:

> Maybe I have used the wrong word. Sorry. If the ports are already in
> cache, the new code has only one cache access for ports, and the later
> operations are in registers.

Ok, that makes more sense - so your commit log is confusing.
You are saving a shift operation per packet - probably not a big deal
but better than zero ;->

cheers,
jamal

