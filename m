From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sat, 24 Apr 2010 12:04:12 -0400
Message-ID: <1272125052.8918.18.camel@bigi>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:59010 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab0DXQEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 12:04:16 -0400
Received: by qyk9 with SMTP id 9so14822414qyk.1
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 09:04:15 -0700 (PDT)
In-Reply-To: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


By the time you hit this code (at least on machines that make sense for
RPS), you already have the ethernet header, IP header and transport
ports in cache, no?
I think the sport << 16 shifting is avoided - but i dont think theres
any effect on mem access.

cheers,
jamal

