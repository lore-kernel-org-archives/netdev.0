From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 16:34:04 +0200
Message-ID: <20131007143404.GA24997@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
 <20131006120612.GA27852@sesse.net>
 <20131007015252.GE9295@order.stressinduktion.org>
 <20131007030910.GG9295@order.stressinduktion.org>
 <20131007083228.GB18903@sesse.net>
 <20131007143206.GH9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:43871 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab3JGOeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 10:34:09 -0400
Content-Disposition: inline
In-Reply-To: <20131007143206.GH9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 04:32:06PM +0200, Hannes Frederic Sowa wrote:
> Strange, I have them in nstat:
> 
> $ nstat -z | egrep  '(TcpExtOutOfWindowIcmps|Icmp6InErrors|TcpExtTCPMinTTLDrop|TcpExtListenDrops)'

-z was the trick. (I've never used nstat before.)

pannekake:~> nstat -z | egrep '(TcpExtOutOfWindowIcmps|Icmp6InErrors|TcpExtTCPMinTTLDrop|TcpExtListenDrops)'              
Icmp6InErrors                   0                  0.0
TcpExtOutOfWindowIcmps          4                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0

Next time it triggers, I'll see if TcpExtOutOfWindowIcmps increases, then.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
