From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] mroute: "ip mroute show" not working when "to"
 and/or "from" is given
Date: Thu, 25 Jun 2015 08:47:47 -0400
Message-ID: <20150625084747.77d9d599@uryu.home.lan>
References: <1434038856-18054-1-git-send-email-ranamazharp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mazhar Rana <ranamazharp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33855 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbbFYMrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:47:51 -0400
Received: by igcsj18 with SMTP id sj18so7430067igc.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 05:47:50 -0700 (PDT)
In-Reply-To: <1434038856-18054-1-git-send-email-ranamazharp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2015 21:37:36 +0530
Mazhar Rana <ranamazharp@gmail.com> wrote:

> The command "ip mroute show" is not showing routes when "to" and/or "from"
> filter is applied.
> 
> root@mazhar:~# ip mroute show
> (10.202.30.101, 235.1.2.3)       Iif: eth0       Oifs: eth1
> 
> But When I applied filter, it does not show anything.
> 
> root@mazhar:~# ip mroute show 235.1.2.3 from 10.202.30.101
> root@mazhar:~#
> 
> Signed-off-by: Mazhar Rana <ranamazharp@gmail.com>

Looks good. Applied
