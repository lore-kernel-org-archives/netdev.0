From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 0/4] ath: logging message conversion
Date: Tue, 7 Dec 2010 11:26:04 -0800
Message-ID: <20101207192604.GA2582@tux>
References: <20101202190239.GE7399@tux>
 <cover.1291333543.git.joe@perches.com>
 <20101207190528.GD2700@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Joe Perches <joe@perches.com>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath5k-devel@venema.h4ckr.net" <ath5k-devel@venema.h4ckr.net>,
	"ath9k-devel@venema.h4ckr.net" <ath9k-devel@venema.h4ckr.net>,
	Peter Stuge <peter@stuge.se>, Felix Fietkau <nbd@openwrt.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 11:25:53 -0800
Content-Disposition: inline
In-Reply-To: <20101207190528.GD2700@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 07, 2010 at 11:05:28AM -0800, John W. Linville wrote:
> On Thu, Dec 02, 2010 at 07:12:34PM -0800, Joe Perches wrote:
> > ath_print is misleading as it's only used with CONFIG_ATH_DEBUG.
> > 
> > Add and use the more normal <subsystem>_printk and <subsystem>_<level>
> > printk equivalents. (ath_printk and ath_<level>)
> > 
> > Fix various defects in the current uses of ath_print formats
> > and arguments: Unnecessary casts, missing newlines, multiple
> > prints, and 1 loop which can exceed array bounds.
> > 
> > Bundled and integrated the individual patches into a single patch series.
> > 
> > Joe Perches (4):
> >   ath: Add and use ath_printk and ath_<level>
> >   ath: Convert ath_print(.., ATH_DBG_FATAL to ath_err
> >   ath: Convert ath_print to ath_dbg
> >   ath: Fix ath_dbg access beyond array bound
> 
> Is the Atheros crew happy with this series?  They didn't seem to like
> the original patches very much...

Its fine now that Joe has addressed some more important items.
But I'd like for the patches to be applied last of all pending
patches :)

  Luis
