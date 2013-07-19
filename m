From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 1/3] team: add peer notification
Date: Fri, 19 Jul 2013 06:56:50 -0700
Message-ID: <1374242210.26476.9.camel@edumazet-glaptop>
References: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
	 <1374241222-9683-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	edumazet@google.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34614 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759578Ab3GSN4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:56:52 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so4267550pdi.30
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:56:52 -0700 (PDT)
In-Reply-To: <1374241222-9683-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-19 at 15:40 +0200, Jiri Pirko wrote:
> When port is enabled or disabled, allow to notify peers by unsolicitated
> NAs or gratuitous ARPs. Disabled by default.
> 

> +	if (!atomic_dec_and_test(&team->notify_peers.count_pending))
> +		schedule_delayed_work(&team->notify_peers.dw,
> +				      (team->notify_peers.interval * HZ) / 1000);

Isn't that msecs_to_jiffies() ?
