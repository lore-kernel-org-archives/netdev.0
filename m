From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH] ath5k: do not free irq after resume when card has been
	removed
Date: Tue, 8 Sep 2009 23:32:37 -0400
Message-ID: <20090909033237.GC13550@hash.localnet>
References: <1252457551-4909-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org, mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1252457551-4909-1-git-send-email-cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 08, 2009 at 09:52:31PM -0300, Thadeu Lima de Souza Cascardo wrote:
> ath5k will try to request irq when resuming and fails if the device
> (like a PCMCIA card) has been removed.

That's not true, ath5k no longer requests an irq when resuming.

> This solves this issue defining a new flag for the status bitmap to
> indicate when irq has been successfully requested and does not try to
> release it if not.

I'd rather not fix it with a status bit.  What kernel is this against?

-- 
Bob Copeland %% www.bobcopeland.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
