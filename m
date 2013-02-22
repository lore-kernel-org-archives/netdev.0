From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] IP_GRE: Fix IP-Identification.
Date: Thu, 21 Feb 2013 18:35:07 -0800
Message-ID: <1361500507.32484.8.camel@edumazet-glaptop>
References: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:50666 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab3BVCfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 21:35:11 -0500
Received: by mail-da0-f51.google.com with SMTP id n15so105689dad.24
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 18:35:10 -0800 (PST)
In-Reply-To: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-21 at 18:18 -0800, Pravin B Shelar wrote:
> Use ip_select_ident_more() to generate and account ids for all
> segments that can be used for segments of a gso packet.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

I am not sure it makes any sense to do that.

Why is it needed ?
