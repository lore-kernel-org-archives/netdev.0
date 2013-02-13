From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: tcp_use_frto crashes on empty tcp_write_queue
Date: Wed, 13 Feb 2013 22:14:17 +0000
Message-ID: <511C1039.9020001@citrix.com>
References: <511C0127.1040604@citrix.com> <1360791453.6884.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frediano Ziglio <frediano.ziglio@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54784 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3BMWO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 17:14:28 -0500
In-Reply-To: <1360791453.6884.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 13/02/13 21:37, Eric Dumazet wrote:
> This doesn't seem to be a standard kernel.

Indeed, this is a XenServer 6.0.2 kernel, which contains changes, 
however the TCP parts are barely modified. The related code path were 
not changed.
I'm trying to determine if this bug could be fixed in an obvious way, so 
let me rephrase my question: if the socket write queue is empty, 
shouldn't we just stop going further instead of dropping a WARN? Or, if 
there is a reason to do so, shouldn't we check at least that returned 
pointer in tcp_use_frto()?

Regards,

Zoltan Kiss
