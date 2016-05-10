From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] net: ircomm, cleanup TIOCGSERIAL
Date: Tue, 10 May 2016 14:16:15 -0400 (EDT)
Message-ID: <20160510.141615.174614051833919078.davem@davemloft.net>
References: <1462777919-10367-1-git-send-email-jslaby@suse.cz>
	<1462777919-10367-2-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-serial@vger.kernel.org,
	linux-kernel@vger.kernel.org, samuel@sortiz.org,
	netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462777919-10367-2-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon,  9 May 2016 09:11:54 +0200

> In ircomm_tty_get_serial_info, struct serial_struct is memset to 0 and
> then some members set to 0 explicitly.
> 
> Remove the latter as it is obviously superfluous.
> 
> And remove the retinfo check against NULL. copy_to_user will take care
> of that.
> 
> Part of hub6 cleanup series.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Acked-by: David S. Miller <davem@davemloft.net>
