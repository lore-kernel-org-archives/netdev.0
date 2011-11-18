From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: b43: BCM 4331: MacBook 8,1: No connection after suspend
Date: Fri, 18 Nov 2011 14:22:18 -0500
Message-ID: <20111118192217.GA2663@tuxdriver.com>
References: <20111118173242.GA2101@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: b43-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Michael Buesch <m@bues.ch>
To: Nico -telmich- Schottelius <nico-linux-20111118@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111118173242.GA2101@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend has nothing to do with b43, and b43 has it's own
mailing list, b43-dev@lists.infradead.org.  Even if it didn't,
linux-wireless@vger.kernel.org would be a more appropriate list than
this one.

John

On Fri, Nov 18, 2011 at 06:32:42PM +0100, Nico -telmich- Schottelius wrote:
> Hello,
> 
> new notebook, new problems (*):
> 
> Running 3.2.0-rc1 on the MacBook Pro 8,1 with the BCM4331
> (14e4:4331) the WLAN indeed works:
> 
> [   86.231702] b43-phy0: Broadcom 4331 WLAN found (core revision 29)
> [   86.269190] ieee80211 phy0: Selected rate control algorithm
> 'minstrel_ht'
> [   86.270486] Broadcom 43xx driver loaded [ Features: PMNLS ]
> [   87.677265] b43-phy0: Loading firmware version 666.2 (2011-02-23
> 01:15:07)
> 
> But: After a suspend it seems not to receive any packets anymore:
> 
> [ 2334.494845] wlan0: authenticate with 64:87:d7:37:89:89 (try 1)
> [ 2334.694035] wlan0: authenticate with 64:87:d7:37:89:89 (try 2)
> [ 2334.893909] wlan0: authenticate with 64:87:d7:37:89:89 (try 3)
> [ 2335.093824] wlan0: authentication with 64:87:d7:37:89:89 timed out
> 
> wpa_supplicant thus retries to connect to the network again and again
> without success.
> 
> This is reproducable on the MBP 8,1 and is *NOT* fixed if I unload
> b43 and modprobe it again. It is also "not fixed" when doing
> multiple suspends/resumes.
> 
> Any pointers to this?
> 
> Cheers,
> 
> Nico
> 
> 
> (*) feels like in good old times...
> 
> -- 
> PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
