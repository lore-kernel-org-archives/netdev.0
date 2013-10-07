From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 16:32:06 +0200
Message-ID: <20131007143206.GH9295@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20131006120612.GA27852@sesse.net> <20131007015252.GE9295@order.stressinduktion.org> <20131007030910.GG9295@order.stressinduktion.org> <20131007083228.GB18903@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45680 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab3JGOcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 10:32:07 -0400
Content-Disposition: inline
In-Reply-To: <20131007083228.GB18903@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 10:32:28AM +0200, Steinar H. Gunderson wrote:
> On Mon, Oct 07, 2013 at 05:09:10AM +0200, Hannes Frederic Sowa wrote:
> > Could you try to check (with e.g. nstat) if any of the following counters
> > change if the icmp messages hit the host?
> > 
> > TcpExtOutOfWindowIcmps
> > Icmp6InErrors
> > TcpExtTCPMinTTLDrop
> > TcpExtListenDrops
> 
> Icmp6InErrors is 0, so that's not it. How do I find the Tcp* counters?
> None of them show up in nstat, although other Tcp* counters do.

Strange, I have them in nstat:

$ nstat -z | egrep  '(TcpExtOutOfWindowIcmps|Icmp6InErrors|TcpExtTCPMinTTLDrop|TcpExtListenDrops)'
Icmp6InErrors                   0                  0.0
TcpExtOutOfWindowIcmps          0                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0

Otherwise you can manually extract them from /proc/net/netstat.

Greetings,

  Hannes
