From: Nico -telmich- Schottelius <nico-linux-20111118@schottelius.org>
Subject: b43: BCM 4331: MacBook 8,1: No connection after suspend
Date: Fri, 18 Nov 2011 18:32:42 +0100
Message-ID: <20111118173242.GA2101@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

new notebook, new problems (*):

Running 3.2.0-rc1 on the MacBook Pro 8,1 with the BCM4331
(14e4:4331) the WLAN indeed works:

[   86.231702] b43-phy0: Broadcom 4331 WLAN found (core revision 29)
[   86.269190] ieee80211 phy0: Selected rate control algorithm
'minstrel_ht'
[   86.270486] Broadcom 43xx driver loaded [ Features: PMNLS ]
[   87.677265] b43-phy0: Loading firmware version 666.2 (2011-02-23
01:15:07)

But: After a suspend it seems not to receive any packets anymore:

[ 2334.494845] wlan0: authenticate with 64:87:d7:37:89:89 (try 1)
[ 2334.694035] wlan0: authenticate with 64:87:d7:37:89:89 (try 2)
[ 2334.893909] wlan0: authenticate with 64:87:d7:37:89:89 (try 3)
[ 2335.093824] wlan0: authentication with 64:87:d7:37:89:89 timed out

wpa_supplicant thus retries to connect to the network again and again
without success.

This is reproducable on the MBP 8,1 and is *NOT* fixed if I unload
b43 and modprobe it again. It is also "not fixed" when doing
multiple suspends/resumes.

Any pointers to this?

Cheers,

Nico


(*) feels like in good old times...

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
