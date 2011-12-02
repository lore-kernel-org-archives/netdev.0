From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: Re: BCM43224: 00:00:00:00:00:00 address (3.2.0-rc3-00099-g883381d)
Date: Fri, 2 Dec 2011 16:01:28 +0100
Message-ID: <20111202150128.GC3096@schottelius.org>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nico Schottelius <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, Greg KH <gregkh@suse.de>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ED8B610.2010703@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Arend,

Arend van Spriel [Fri, Dec 02, 2011 at 12:27:12PM +0100]:
> Have you tried the brcmsmac driver?


I've been mislead: bcma was enabled and thus brcmsmac
not shown in menuconfig.

Upgrade the kernel to 3.2.0-rc4-00077-g5983fe2, fired
up wpa_supplicant. Result: wpa_cli can connect to wpa_supplicant,
but stops working after a few seconds:

wpa_state=ASSOCIATING
> 'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
> 'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.

No network connectivity and network processes are hanging.
I.e. same behaviour as reported on 2011-10-18.

Is it possible the related patch as discussed
in "BUG: All network processes hang (brcmsmac/wpa_supplicant)"
has not been merged into 3.2.0-rc4-00077-g5983fe2?

And regarding b43: Wouldn't it be good to remove support for the
specific pci-ids from it so it does not create a non-functional
wlan0 device?

Cheers,

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
