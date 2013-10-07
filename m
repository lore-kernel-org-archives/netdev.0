From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 07 Oct 2013 08:49:36 -0700
Message-ID: <1381160976.12191.16.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130927201420.GB12043@sesse.net>
	 <20130928203318.GC23654@order.stressinduktion.org>
	 <20131006120612.GA27852@sesse.net>
	 <20131007015252.GE9295@order.stressinduktion.org>
	 <20131007030910.GG9295@order.stressinduktion.org>
	 <20131007083228.GB18903@sesse.net>
	 <20131007143206.GH9295@order.stressinduktion.org>
	 <20131007143404.GA24997@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:58595 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3JGPtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 11:49:39 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so7192389pbc.8
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 08:49:39 -0700 (PDT)
In-Reply-To: <20131007143404.GA24997@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 16:34 +0200, Steinar H. Gunderson wrote:
> On Mon, Oct 07, 2013 at 04:32:06PM +0200, Hannes Frederic Sowa wrote:
> > Strange, I have them in nstat:
> > 
> > $ nstat -z | egrep  '(TcpExtOutOfWindowIcmps|Icmp6InErrors|TcpExtTCPMinTTLDrop|TcpExtListenDrops)'
> 
> -z was the trick. (I've never used nstat before.)

Best might be to use -a  (absolute counters).
