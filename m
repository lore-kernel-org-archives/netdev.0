From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: Q: ieee80211_txb
Date: Mon, 30 May 2005 10:34:18 +0800
Message-ID: <1117420458.24850.36.camel@debian.sh.intel.com>
References: <Pine.SOC.4.61.0505291343360.4341@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0505291343360.4341@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-05-29 at 13:47 +0300, Meelis Roos wrote:
> I tried to understand the new 802.11 stack API and met some things I 
> couldn't understand by just looking at the code.
> 
> My main question is currently struct ieee80211_txb. How is it meant to 
> be used? How driver-specific is it - should it fit all drivers or does 
> it assume some specific DMA set-up?

The ieee80211_txb should not be driver specific. ->fragments is struct
sk_buff, indicates the packet skb or the fragmentation skb list for
software based fragmentation. And others members are self explained.
Currently it fits the ipw* drivers (you see a reserved word is used), we
should change it to be more generic and provide enough info for every
wireless driver.

Thanks,
-yi
