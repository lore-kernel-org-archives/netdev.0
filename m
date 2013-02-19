From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Tue, 19 Feb 2013 00:52:06 -0500 (EST)
Message-ID: <20130219.005206.397289032011003833.davem@davemloft.net>
References: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361156480-32566-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date: Sun, 17 Feb 2013 21:01:20 -0600

> Bastian Bittorf reported that some of the silent freezes on a Linksys WRT54G
> were due to overflow of the RX DMA ring buffer, which was created with 64
> slots. That finding reminded me that I was seeing similar crashed on a netbook,
> which also has a relatively slow processor. After increasing the number of
> slots to 128, runs on the netbook that previously failed now worked; however,
> I found that 109 slots had been used in one test. For that reason, the number
> of slots is being increased to 256.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
