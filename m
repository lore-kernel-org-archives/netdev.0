From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: more rc1 lockdep fun.
Date: Fri, 07 Jul 2006 21:03:35 +0200
Message-ID: <1152299015.3111.138.camel@laptopd505.fenrus.org>
References: <20060707185848.GA5818@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51929 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750800AbWGGTDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:03:37 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060707185848.GA5818@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-07 at 14:58 -0400, Dave Jones wrote:
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> -------------------------------------------------------
> gnome-settings-/3278 is trying to acquire lock:
>  (sk_lock-AF_INET){--..}, at: [<ffffffff8022800c>] tcp_sendmsg+0x1f/0xb1a


this appears to be the same one as the "mc" one I just looked at.


