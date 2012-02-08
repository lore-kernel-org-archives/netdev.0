From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] rtlwifi/rtl8192c: in _rtl92c_phy_calculate_bit_shift
 remove comparing bitmask against 1
Date: Wed, 8 Feb 2012 14:57:44 -0500
Message-ID: <20120208195744.GD2929@tuxdriver.com>
References: <1327993863-6810-1-git-send-email-devendra.aaru@gmail.com>
 <1327995440.1804.16.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Devendra.Naga" <devendra.aaru@gmail.com>,
	Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	paul.gortmaker@windriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1327995440.1804.16.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 11:37:20PM -0800, Joe Perches wrote:
> On Tue, 2012-01-31 at 02:11 -0500, Devendra.Naga wrote:
> > From: "Devendra.Naga" <devendra.aaru@gmail.com>
> []
> > diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> []
> > @@ -177,7 +177,7 @@ u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask)
> >  	u32 i;
> >  
> >  	for (i = 0; i <= 31; i++) {
> > -		if (((bitmask >> i) & 0x1) == 1)
> > +		if ((bitmask >> i) & 0x1)
> >  			break;
> >  	}
> >  	return i;
> 
> Perhaps this is simpler and faster:
> 
> {
> 	u32 rtn = (u32)ffs((int)bitmask);
> 	if (rtn)
> 		return rtn - 1;
> 	return 32;
> }

Are you planning to revise your patch based on Joe's suggestion?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
