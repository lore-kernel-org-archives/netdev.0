From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v6 5/6] PM / Runtime: force memory allocation with no I/O
 during Runtime PM callbcack
Date: Wed, 28 Nov 2012 11:06:43 +0800
Message-ID: <CACVXFVOAt8hrNenEthRZEqv2d6g+gzSPUCBV=RU_u=bxs+9VTw@mail.gmail.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<1353761958-12810-6-git-send-email-ming.lei@canonical.com>
	<1354069667.BsTEhItmLz@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>,
	Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1354069667.BsTEhItmLz@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 5:24 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Please don't duplicate code this way.
>
> You can move that whole thing to rpm_callback().  Yes, you'll probably need to
> check dev->power.memalloc_noio twice in there, but that's OK.

Good idea, I will update it in v7.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
