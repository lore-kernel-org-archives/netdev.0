From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH 2/2] ath: Fix logging message typos
Date: Wed, 01 Dec 2010 21:34:47 -0800
Message-ID: <1291268087.1761.3.camel@Joe-Laptop>
References: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
	 <a345e995a816576a4c2c39aec43716c18011475b.1291266731.git.joe@perches.com>
	 <20101202053055.19479.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
To: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101202053055.19479.qmail-Y+HMSxxDrH8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-02 at 06:30 +0100, Peter Stuge wrote:
> Joe Perches wrote:
> > +++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
> ..
> > @@ -734,7 +734,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
> >  	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
> >  			  0, AH_WAIT_TIMEOUT)) {
> >  		ath_dbg(common, ATH_DBG_CALIBRATE,
> > -			"offset calibration failed to complete in 1ms; noisy ??\n");
> > +			"offset calibration failed to complete in 1ms; noisy enfironment?\n");
> 
> enfironment? :)

Umm, what's a typo fix patch without more typos?
Correct?  How dull...

> >  	ath_dbg(common, ATH_DBG_ANI,
> > -		"Getting spur idx %d is2Ghz. %d val %x\n",
> > +		"Getting spur idx:%d is2Ghz:%d val:%x\n",
> >  		i, is2GHz, ah->config.spurchans[i][is2GHz]);
> 
> Is this short for "spurious" ?

Likely.  Anyone want to change it to a whole word?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
