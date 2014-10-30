From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: nfs stalls over loopback interface (no sk_data_ready events?)
Date: Thu, 30 Oct 2014 12:00:35 -0700
Message-ID: <20141030190035.GA23129@infradead.org>
References: <20141027152900.4e81a9d5@tlielax.poochiereds.net>
 <20141029102123.58f6c960@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
To: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141029102123.58f6c960-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 10:21:23AM -0400, Jeff Layton wrote:
> Looks some change that went into -rc2 has fixed the problem for me.
> Christoph, can you confirm that this no longer occurs with -rc2?

I can't reproduce it anymore on -rc2.


However:

generic/133 fails fairly reliably with:

	 Buffered writer, buffered reader
	+pread64: Device or resource busy


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
