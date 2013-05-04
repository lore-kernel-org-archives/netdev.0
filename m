From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: add fastopen support
Date: Fri, 03 May 2013 20:53:29 -0700
Message-ID: <1367639609.22983.7.camel@edumazet-glaptop>
References: <1364590317.5113.63.camel@edumazet-glaptop>
	 <20130503204218.5a7d537f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:58601 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3EDDxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 23:53:31 -0400
Received: by mail-da0-f43.google.com with SMTP id u7so1076392dae.16
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 20:53:31 -0700 (PDT)
In-Reply-To: <20130503204218.5a7d537f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 20:42 -0700, Stephen Hemminger wrote:

> Ok, but the header stuff needs work.
> 
> The headers from iproute2 come from the kernel sanitized headers (ie make headers_install)
> The only definition of TCPI_OPT_ECN_SEEN in those headers is in <linux/tcp.h>
> I will tweak the ss to use linux/tcp.h

Thanks, this seems good to me.
