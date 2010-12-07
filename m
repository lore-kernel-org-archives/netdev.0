From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/4] ath: logging message conversion
Date: Tue, 7 Dec 2010 14:05:28 -0500
Message-ID: <20101207190528.GD2700@tuxdriver.com>
References: <20101202190239.GE7399@tux>
 <cover.1291333543.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1291333543.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2010 at 07:12:34PM -0800, Joe Perches wrote:
> ath_print is misleading as it's only used with CONFIG_ATH_DEBUG.
> 
> Add and use the more normal <subsystem>_printk and <subsystem>_<level>
> printk equivalents. (ath_printk and ath_<level>)
> 
> Fix various defects in the current uses of ath_print formats
> and arguments: Unnecessary casts, missing newlines, multiple
> prints, and 1 loop which can exceed array bounds.
> 
> Bundled and integrated the individual patches into a single patch series.
> 
> Joe Perches (4):
>   ath: Add and use ath_printk and ath_<level>
>   ath: Convert ath_print(.., ATH_DBG_FATAL to ath_err
>   ath: Convert ath_print to ath_dbg
>   ath: Fix ath_dbg access beyond array bound

Is the Atheros crew happy with this series?  They didn't seem to like
the original patches very much...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
