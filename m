From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: small optim in tcp_show_info()
Date: Mon, 11 May 2015 09:16:12 -0700
Message-ID: <20150511091612.2cf9e971@urahara>
References: <1430937203.14545.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33777 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbbEKQQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:16:09 -0400
Received: by pdbnk13 with SMTP id nk13so150013856pdb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:16:09 -0700 (PDT)
In-Reply-To: <1430937203.14545.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 May 2015 11:33:23 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Kernel can give us smaller tcp_info than our.
> 
> We copy the kernel provided structure and fill with 0
> the remaining part.
> 
> Lets clear only the missing part to save some cycles, as we intend to
> slightly increase tcp_info size in the future.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, I don't think other people will have enough sockets to notice the difference :-)
