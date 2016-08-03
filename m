From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Wed, 3 Aug 2016 11:51:09 +0900
Message-ID: <bb69b031-53ad-4649-bd1d-e95ca7a0cc70@gmail.com>
References: <20160713200755.26839-1-yanivma@ti.com>
 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
 <1470045822.3389.24.camel@sipsolutions.net>
 <75fef3ce-41a6-5845-e9be-d7ff052a07da@gmail.com>
 <1c2d3cfc-b7fd-c8fd-4f74-14dd3aa3076e@gmail.com>
 <1470122837.2665.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org,
	Meirav Kama <meiravk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470122837.2665.5.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016年08月02日 16:27, Johannes Berg wrote:
> This explicitly configures *HT capability* though - that's even the
> name of the parameter. If you enable HT40 in the capability, the
> resulting BSS might still not actually *use* 40 MHz bandwidth, as
> required by overlapping BSS detection.

OK, I see.

HT Capabilities element = Defined by hardware and software spec of the 
node. So it does not be modified after boot.

HT Operation element = Defined by surrounding environment and 
configuration of the node. So it could be modified after boot.

So, if the node supports HT40, HT Capabilities shows HT40 is capable.
Now, I understand why you rejected this patch.

But now, when disable_ht=1, no HT Capabilities element in beacon even 
though the node supports HT.

My trailing patch could solve the issue.

Masashi Honma.
