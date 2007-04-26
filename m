From: Olaf Kirch <okir@lst.de>
Subject: Re: very strange inet_sock corruption with rpc
Date: Thu, 26 Apr 2007 08:49:40 +0200
Message-ID: <200704260849.41485.okir@lst.de>
References: <462FC238.4040305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:42590 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933099AbXDZGtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 02:49:55 -0400
In-Reply-To: <462FC238.4040305@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 April 2007 23:03, Vlad Yasevich wrote:
> It looks like someone is stepping all over the inet_sock.
> We'll continue looking, but if anyone has any ideas of what might
> be going on, I'd appreciate it.

This could be a socket in TIME_WAIT. A socket entering
TIME_WAIT will be replaced by an inet_timewait_sock, which is
a kind of truncated inet_sock.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
