From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: add fastopen support
Date: Fri, 3 May 2013 20:42:18 -0700
Message-ID: <20130503204218.5a7d537f@nehalam.linuxnetplumber.net>
References: <1364590317.5113.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63147 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab3EDDmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 23:42:36 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa10so1214166pad.5
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 20:42:35 -0700 (PDT)
In-Reply-To: <1364590317.5113.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Mar 2013 13:51:57 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> ss -i can output "fastopen" attribute if socket used Fast Open
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Ok, but the header stuff needs work.

The headers from iproute2 come from the kernel sanitized headers (ie make headers_install)
The only definition of TCPI_OPT_ECN_SEEN in those headers is in <linux/tcp.h>
I will tweak the ss to use linux/tcp.h
