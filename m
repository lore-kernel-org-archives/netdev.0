From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Mon, 20 Jan 2014 19:40:25 +0100
Message-ID: <20140120184025.GA19972@sesse.net>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:33177 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaATSk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 13:40:29 -0500
Content-Disposition: inline
In-Reply-To: <20140119181806.GC16462@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 19, 2014 at 07:18:06PM +0100, Hannes Frederic Sowa wrote:
> I currently only remember one commit 0a7e22609067ff ("ipv4: fix
> ineffective source address selection") which did affect multicast source
> address selection in recent times.

I tried 3.10.27, just to check something older. I also tried 3.10.27 with
0a7e22609067ff reverted, and it's still wrong.

I am thinking this might have something to do with the machine switching to
systemd, presumably changing the order of DHCP and static addresses being
assigned...

/* Steinar */
-- 
Homepage: http://www.sesse.net/
