From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 10:32:28 +0200
Message-ID: <20131007083228.GB18903@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
 <20131006120612.GA27852@sesse.net>
 <20131007015252.GE9295@order.stressinduktion.org>
 <20131007030910.GG9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:52733 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab3JGIca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 04:32:30 -0400
Content-Disposition: inline
In-Reply-To: <20131007030910.GG9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 05:09:10AM +0200, Hannes Frederic Sowa wrote:
> Could you try to check (with e.g. nstat) if any of the following counters
> change if the icmp messages hit the host?
> 
> TcpExtOutOfWindowIcmps
> Icmp6InErrors
> TcpExtTCPMinTTLDrop
> TcpExtListenDrops

Icmp6InErrors is 0, so that's not it. How do I find the Tcp* counters?
None of them show up in nstat, although other Tcp* counters do.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
