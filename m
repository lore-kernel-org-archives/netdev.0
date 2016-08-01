From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Mon, 1 Aug 2016 21:30:12 +0900
Message-ID: <75fef3ce-41a6-5845-e9be-d7ff052a07da@gmail.com>
References: <20160713200755.26839-1-yanivma@ti.com>
 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
 <1470045822.3389.24.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org,
	Meirav Kama <meiravk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470045822.3389.24.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016年08月01日 19:03, Johannes Berg wrote:
>
> But why is that behaviour *correct*? We still support 40 MHz bandwidth
> things, we just don't use them if we disable HT40.

I could not fully understand your concern...

Do you mean we have 2 bugs about disabling HT40 ?

1) bits in HT capabilities IE
2) HT40 still enabled even if it was disabled by wpa_supplicant or 
hostapd with disable_ht40

And do you mean 1) and 2) should be fixed at one time ?
Indeed, currently on the view point of opposite peer, HT40 was enabled 
even though it was disabled because both 1) and 2) are wrong.
But if only 1) was fixed, this causes unmatch.

Now I do not recognize bug 2).
Do you have any information about 2) ?
