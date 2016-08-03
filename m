From: Alan Curry <rlwinm@sdf.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 3 Aug 2016 23:25:26 +0000 (UTC)
Message-ID: <201608032325.u73NPQ3w016047@sdf.org>
References: <1882749.mb7lsAROoU@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Curry <rlwinm@sdf.org>, Al Viro <viro@zeniv.linux.org.uk>,
	alexmcwhirter@triadic.us, David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1882749.mb7lsAROoU@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Lamparter wrote:
> 
> One thing I noticed in your previous post is that you "might" not have
> draft-802.11n enabled. Do you see any "disabling HT/VHT due to WEP/TKIP use."
> in your dmesg logs? If so, check if you can force your AP to use WPA2
> with CCMP/AES only.
> 

Yes, I've had that message. The reason wan't on the AP though. My
wpa_supplicant.conf only had TKIP enabled, because that's what was in the
sample configuration file I started with. Adding CCMP there worked, and in
that mode I'm no longer getting any corrupted packets.

If I'd paid attention to the encryption options when setting up this network
originally, I would have had CCMP the whole time, with no corrupted packets,
and never would have found the iov iterator bug...

-- 
Alan Curry
