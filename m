From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][TG3] fix tx timeout after setting mtu
Date: Sun, 20 Apr 2003 13:19:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EA2D6A6.6070809@pobox.com>
References: <Pine.LNX.4.44.0304201632010.3657-100000@dp.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamesm@samba.org
In-Reply-To: <Pine.LNX.4.44.0304201632010.3657-100000@dp.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamesm@samba.org wrote:
> This patch against recent bk stops a tx timeout when setting the mtu.


hmmm, gonna have to think on this a bit...  tg3_netif_start calls 
netif_wake_queue, which _should_ take care of this problem.  According 
to you it doesn't, so we need to figure out why...

	Jeff
