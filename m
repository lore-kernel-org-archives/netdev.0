From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH RFC v2] ath10k: move code from parameter list into a
	function
Date: Wed, 11 Mar 2015 20:15:26 +0100
Message-ID: <20150311191526.GA24455@opentech.at>
References: <1426100519-20636-1-git-send-email-hofrat@osadl.org> <1426101010.1904.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>, Valdis.Kletnieks@vt.edu,
	Bj??rn Mork <bjorn@mork.no>,
	Jeff Haran <Jeff.Haran@citrix.com>,
	Pat Erley <pat-lkml@erley.org>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426101010.1904.9.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Mar 2015, Johannes Berg wrote:

> On Wed, 2015-03-11 at 15:01 -0400, Nicholas Mc Guire wrote:
> > Putting code into the parameter list of wait_event_timeout() might be
> > legal C-code but not really readable - the "inline" code is simply
> > moved into a function and that passed to wait_event_timeout() as the
> > condition.
> 
> Arguably, that's even more unreadable since if you don't know this macro
> well you might assume the function is called only once, which is clearly
> not true...
> 
> Don't get me wrong, I'm not opposed to this change, but if you ask me
> it's not completely clear that this makes it more readable.
>
I'm not into this long enough to say what is better and if the consensus
is that this patch is no more readable than the original code
and no more maintainable either, then it is not worth the effort.

so thanks for your comments!

thx!
hofrat 
