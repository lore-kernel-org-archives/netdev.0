From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] Dynamic airo.c patch for 2.6.10
Date: Wed, 2 Feb 2005 10:35:25 -0800
Message-ID: <20050202183525.GA13881@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Benjamin Reed <breed@almaden.ibm.com>, Javier Achirica <achirica@ttd.net>,
        netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Benjamin Reed wrote :
> 
> Here is a patch for the 2.6.10 aironet driver that
> will enable dynamic wep keying without resetting the
> MAC. It allows us to use xsupplicant with the driver.
> 
> There are two lines of ugliness (the ones with the 0
> &&) where I ignore the flag that says wether we are
> setting a permanent or a temporary key since
> xsupplicant doesn't use the IW_ENCODE_TEMP flag.

	The IW_ENCODE_TEMP flag only make sense for the Aironet
driver, as for all other hardware the WEP keys are volatile. So, don't
expect this flag to be widespread.
	I would suggest you send a nice little patch to the maintainer
of xsupplicant (and wpa_supplicant as well) explaining the
situation. Enabling this flag should not affect other drivers, and
might actually be a good idea in general.
	Have fun...

	Jean
