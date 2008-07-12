From: Pavel Machek <pavel@suse.cz>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 12 Jul 2008 09:01:51 +0200
Message-ID: <20080712070150.GD13483@ucw.cz>
References: <20080707180736.GA15687@2ka.mipt.ru> <20080707181019.GC15687@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080707181019.GC15687@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> + * Completely async processing of all events (hard, symlinks and rename are the
> + 	only exceptions) including object creation and data reading and writing.

Hmm... this is little funny.

	Async processing of most events (only exceptions are ...) ?


> +POHMELFS network protocol.
> +
> +Basic structure used in network communication is following command:
> +
> +struct netfs_cmd
> +{
> +	__u16			cmd;	/* Command number */
> +	__u16			csize;	/* Attached crypto information size */
> +	__u16			cpad;	/* Attached padding size */
> +	__u16			ext;	/* External flags */
> +	__u32			size;	/* Size of the attached data */
> +	__u32			trans;	/* Transaction id */
> +	__u64			id;	/* Object ID to operate on. Used for feedback.*/
> +	__u64			start;	/* Start of the object. */
> +	__u64			iv;	/* IV sequence */
> +	__u8			data[0];
> +};

Which endianity?

							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
