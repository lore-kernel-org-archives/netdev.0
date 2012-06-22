From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-06-22
Date: Fri, 22 Jun 2012 16:09:18 -0700 (PDT)
Message-ID: <20120622.160918.90088993233016911.davem@davemloft.net>
References: <20120622201716.GB13918@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120622201716.GB13918@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 22 Jun 2012 16:17:16 -0400

> Another quick round of fixes intended for 3.5...
> 
> Some of them are Bluetooth -- quoth Gustavo:
> 
> 	Five fixed to 3.5. There 2 new usb devices id commits, one
> 	driver fix and two other fixes for the core, one for L2CAP
> 	and other in MGMT interface.
> 
> The Bluetooth fixes look reasonable to me.
> 
> The mwifiex drivers gets a fix from Avinash Patil for a potential
> stuck tx queue in AP mode, and a fix from Bing Zhao for a crash from
> a bad return type.
> 
> Bob Copeland gives us a two-liner for ath5k to avoid a bottom half
> double lock.
> 
> Dan Carpenter gives us an airo fix to correct some incorrect pointer
> usage in a memcpy.
> 
> The wl1251 driver gets three fixes that Grazvydas Ignotas rescued from
> the Maemo repos.  One corrects a TSF calculation, another ensures
> that beacon losses are always reported up the stack, and the third
> corrects some memory leaks.
> 
> Johannes Berg gives us an iwlwifi fix to avoid a debugfs-releated
> crash.
> 
> Finally, the ath9k folks were busy!  Felix Fietkau fixes a tx rate
> duration calculation and an invalid pointer access, Mohammed Shafi
> Shajakhan avoids a potential infinite loop, and Rajkumar Manoharan
> ensures that the bssid is configured for ath9k_htc when association
> or ibss information changes.
> 
> Please let me know if there are problems!

Pulled, thanks John.
