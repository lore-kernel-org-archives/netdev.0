From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 10:29:14 +0200
Message-ID: <20131007082914.GA18903@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
 <20131006120612.GA27852@sesse.net>
 <20131007015252.GE9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:34436 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab3JGI3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 04:29:21 -0400
Content-Disposition: inline
In-Reply-To: <20131007015252.GE9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 03:52:52AM +0200, Hannes Frederic Sowa wrote:
>> 2001067c00a400037c4d9ae8ab73230f 80 00000000000000000000000000000000 00 fe80000000000000023048fffe555743 00000000 00000001 00000137 01000023     eth0
> Did you take the snapshot while the tcp connection was hanging? We normally
> take 2 references to the rt6_info while the tcp connection is running, this
> oddly only has one (but got used a lot). But doing a judgement on the
> reference count is imprecise.

This was while the problem was present; I had broken the TCP connection,
though.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
