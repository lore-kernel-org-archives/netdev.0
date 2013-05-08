From: Greg KH <gregkh@linux-foundation.org>
Subject: Re: Linux driver for Realtek RTL8723AU devices with USB ID 0bda:1724
 such as found in Lenovo IdeaPad Yoga 13
Date: Wed, 8 May 2013 09:23:50 -0700
Message-ID: <20130508162350.GC28080@kroah.com>
References: <5159B52D.3050601@lwfinger.net>
 <5189B939.4010905@zytor.com>
 <518A7814.1070604@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>,
	'George0505' <george0505@realtek.com>,
	Joon Ro <joonhyoung.ro@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <518A7814.1070604@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 08, 2013 at 11:06:44AM -0500, Larry Finger wrote:
> On 05/07/2013 09:32 PM, H. Peter Anvin wrote:
> >
> >So I can verify that this driver works against 3.8.11 (not against
> >current -linus because of a build failure), and yes, there is Bluetooth
> >in this device.  In fact, it seems to work better than some in-tree
> >drivers I have seen in the past.
> >
> >However, I'm confused as to the above and what it implies for the
> >purpose of the staging tree.  Wasn't the whole point of the staging tree
> >to have a working-but-ugly driver upstream and have the work to clean it
> >up happen in the mainline tree instead of off somewhere.
> 
> Yes, but even staging has some standards.

I have standards?  That's a first :)

> For example, they frown on inclusion of firmware in a massive data
> block in a file in the driver - it should be in a separate file the
> /lib/firmware/ tree.

Sure, that would be "nice", but it's not something that I should reject
a driver for, have I done that?

> In addition, the mainline drivers/net/wireless/ tree is only available
> to devices that use mac80211 for the software-based MAC layer. That
> conversion is a serious effort that may never be done, thus the
> 8723au driver may never leave staging.

That's a bigger deal, but note, some drivers have done it, it is not
impossible.

thanks,

greg k-h
