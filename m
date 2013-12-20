From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] Initialize arguments to iplink_parse() by default
Date: Fri, 20 Dec 2013 08:27:07 -0800
Message-ID: <20131220082707.674bad28@nehalam.linuxnetplumber.net>
References: <cover.1386764590.git.popovich_sergei@mail.ru>
	<4467313.PgxQL6MHJm@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:45346 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573Ab3LTQ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:27:10 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so2796761pbb.36
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:27:10 -0800 (PST)
In-Reply-To: <4467313.PgxQL6MHJm@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Be consistent when dealing with arguments passed
> to iplink_parse() by initializing to default values.
> 
> This fixes crash when ip-link(8) invoced with command:
> 
>   ip link add dev veth1a type veth peer
> 
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

Rather than modifying iplink_parse, I just fixed in veth code where the bug
was being caused.
