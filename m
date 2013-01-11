From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: check if packet is overdue on asynchronous code
 path
Date: Fri, 11 Jan 2013 09:29:00 +0100
Message-ID: <20130111082900.GX18940@secunet.com>
References: <1357891965-8047-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35023 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab3AKI3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 03:29:04 -0500
Content-Disposition: inline
In-Reply-To: <1357891965-8047-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 04:12:45PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Currently checking is only done on synchronous code path,
> we should do the same checking on asynchronous code path.

We do this check already before we enter the asynchronous code path,
there is no need to do this check again.
